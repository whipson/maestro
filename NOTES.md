# maestro 1.2.0 Release Notes

## Terminology Reference

| Pattern | Also known as | Description |
|---|---|---|
| Fan-out | Scatter, Broadcast, Map | 1 → N downstream executions |
| Fan-in | Gather, Merge, Join | N → 1 downstream execution |
| Fork-join | — | Fan-out immediately followed by fan-in |

---

## Feature 1: Dynamic Fan-Out (Scatter) ✅

**Concept:** When an upstream pipeline returns a list or vector, a downstream declared with `@maestroInputs upstream` + `@maestroMap` executes once per element. All iterations are housed in a single `MaestroPipeline` object (consistent with the existing multi-execution model).

---

### Syntax

**Simple case** — upstream returns a vector/list; empty `@maestroMap` iterates over each element directly:

```r
#' @maestroInputs upstream
#' @maestroMap
downstream <- function(.input) { ... }
```

**Complex case** — upstream returns a named list; `@maestroMap` selects the iterator element:

```r
#' @maestroInputs upstream
#' @maestroMap .input$vec
downstream <- function(.input) { ... }
```

`@maestroMap` also supports multiple selectors (pmap-style):

```r
# Multi-selector (pmap-style) — zips across two fields simultaneously
#' @maestroMap .input$ids .input$labels
```

---

### `.input` shape contract inside the branch

| `@maestroMap` form | `.input` shape |
|---|---|
| Empty tag (no value) | Raw element of the upstream return value |
| Single selector | Full list with iterated field replaced by its i-th element |
| Multi-selector | Full list with all specified fields replaced by their i-th elements |

---

### `@maestroMap` tag

- Fan-out is driven entirely by the presence of `@maestroMap` on the downstream pipeline. No special syntax is needed in `@maestroInputs`.
- Selector expressions in `@maestroMap` are validated at `build_schedule()` time: any expression that cannot be parsed by `str2lang()` produces a `cli_abort()`.
- At runtime, expressions are evaluated via `eval(str2lang(expr), envir = list(.input = effective_input))`.

**Validation at `build_schedule()` time:**
- Invalid R expressions in `@maestroMap` → `cli_abort()` ✅
- Pipeline names inside `collect()` must resolve to known pipelines → `cli_abort()` ✅

---

### Runtime execution

`run_pipe()` is a recursive closure defined inside `MaestroPipelineList$run()`. It:
1. Calls `pipe$run(...)` once
2. Gets the return value via `pipe$get_returns()`
3. Looks up downstream names from the network: `out_names <- network$to[network$from == pipe$get_pipe_name()]`
4. Recurses into each downstream, passing `.input = .input`
5. Short-circuits on error/not-run status

For fan-out (`get_is_map() == TRUE`): `purrr::iwalk` iterates over the scatter input, calling `run_pipe(pipe, .input = item, iter = label)` for each element. All iterations write into the same `MaestroPipeline` object, distinguished by `internal_run_id`.

---

### Settled decisions

| Decision | Resolution |
|---|---|
| Fan-out mechanism | `@maestroMap` tag on the downstream pipeline |
| Real exported function? | No |
| `.input` contract (empty tag) | Raw element of the upstream return value |
| `.input` contract (field selector) | Full list with selected fields replaced by i-th element |
| Runtime architecture | Multiple executions on one `MaestroPipeline` object |
| Branch identity | `downstream[1]`, `downstream[2]`, ... |
| Error semantics | Continue on branch failure; all errors collected as normal |
| Cancel-on-first-failure | Deferred post-v1.2.0 |
| `@maestroRunIf` | Evaluated once per branch with that branch's `.input` |

---

## Feature 2: Fan-In (Gather/Merge) ✅

**Concept:** A downstream pipeline collects outputs from multiple upstream nodes and receives all of them together as `.input`. The `collect()` marker is required in all fan-in cases — without it, maestro cannot know to wait for all upstream results before executing the downstream.

Two sub-cases:
- **Static fan-in** — downstream names multiple specific independent upstream pipelines.
- **Dynamic fan-in** — downstream gathers all branches produced by a prior fan-out (fork-join pattern).

---

### Syntax

**Static fan-in** — collect from multiple named independent pipelines:

```r
#' @maestroInputs collect(upstream_a, upstream_b)
downstream <- function(.input) {
  # .input$upstream_a — result of upstream_a
  # .input$upstream_b — result of upstream_b
}
```

**Dynamic fan-in (fork-join)** — collect all branches from a prior fan-out:

```r
#' @maestroInputs collect(upstream)  # upstream uses @maestroMap
downstream <- function(.input) {
  # .input is an unnamed list of length n (one element per successful branch)
  # .input[[1]], .input[[2]], ...
}
```

---

### `.input` shape contract

| Case | `.input` shape |
|---|---|
| Static fan-in | Named list keyed by pipeline name |
| Dynamic fan-in (fork-join) | Unnamed list of successful iteration results |

---

### `collect()` marker

- `collect()` is **not** an exported function. It is a marker recognised only during tag parsing, consistent with `@maestroRunIf`.
- Whether the upstream uses `@maestroMap` or not is resolved at runtime — `collect()` on a non-map upstream is valid (static fan-in).

**Validation at `build_schedule()` time** (in `validate_network()`):
- Pipeline names inside `collect()` must resolve to known pipelines → `cli_abort()` ✅
- `collect()` with fewer than two inputs, where the single input is not a `@maestroMap` pipeline → `cli_abort()` ✅

**Deferred:** aliasing in `collect()` (e.g. `collect(cust = upstream_customers, ord = upstream_orders)`) — not necessary since users can rename inside the function body. Deferred post-v1.2.0.

---

### Runtime execution — collect guards

All collect readiness logic is centralised in `private$resolve_collect_input(pipe, network)` in `MaestroPipelineList`. Returns the named `.input` list if ready, `NULL` if the collect should not fire.

Guards (in order):
1. **Already invoked** — `pipe$get_status_chr() != "Not Run"` → skip. Collect fires exactly once per execution regardless of how many branches reach it.
2. **Non-map inputs** — all must have status `"Success"`. An errored non-map input has no meaningful return value; the collect is skipped entirely.
3. **Map inputs** — all iterations must have finished (succeeded *or* errored), checked via `get_n_invocations()`. At least one iteration must have succeeded (`get_n_artifacts() > 0`).

`.input` assembly:
- For `@maestroMap` upstreams: `get_all_returns()` — plain unnamed list of all successful iteration results.
- For normal upstreams: `get_returns()` — the single return value.

---

### Runtime execution — multicore

In multicore mode (`cores > 1`), `furrr::future_map` serialises the entire `MaestroPipelineList` into each worker. Workers cannot see each other's state, so a collect pipe whose inputs span independent primary branches is never triggered inside any worker.

**Fix:** `MaestroPipelineList$run_pending_collects(...)` is called by `MaestroSchedule$run()` after `update_pipelines()` syncs worker results back to the main process. It contains its own `run_pipe` closure (mirroring the one in `run()`) so that the collect pipe's own downstream outputs are recursed into normally.

Sequencing in `MaestroSchedule$run()`:
```
pipes_that_ran <- do.call(pipes_to_run$run, dots)   # workers run primaries
update_pipelines(pipes_that_ran)                      # sync worker state to main process
run_pending_collects(dots)                            # fire collect + recurse on main process
```

---

### Error semantics

| Case | Behaviour |
|---|---|
| Non-map input errors | Collect is skipped entirely |
| Map input: some iterations error | Collect fires with only the successful iterations' results |
| Map input: all iterations error | Collect is skipped entirely |

---

### Settled decisions

| Decision | Resolution |
|---|---|
| Marker name | `collect()` |
| Real exported function? | No |
| Static fan-in `.input` shape | Named list keyed by pipeline name |
| Dynamic fan-in `.input` shape | Unnamed list of successful results |
| `collect()` on non-`@maestroMap` upstream | Valid — no build-time error |
| Collect fires how many times | Exactly once per execution |
| Aliasing in `collect()` | Deferred post-v1.2.0 |
| Partial map failure | Collect proceeds with successful results |
| Full map failure | Collect skipped |

---

### Scheduling constraint for collect

For a fan-in to actually execute, **all named upstream pipelines must be scheduled in the same orchestrator run**. If any upstream is not scheduled (wrong frequency, skipped, future start time, etc.), the collect node will wait indefinitely.

**Status:** Runtime warning when a collect node's upstream set is only partially scheduled — deferred post-v1.2.0.

---

## Implementation Checklist

### Step 1 — `MaestroPipeline`: new fields ✅

Added to `initialize()` and private fields:
- `is_collect` (logical, default `FALSE`)
- `map` (character vector of R expression strings, or `NULL`)

Getters added: `get_is_collect()`, `get_is_map()`, `get_map()`, `get_n_artifacts()`, `get_n_invocations()`, `get_all_returns()`.

`get_is_map()` returns `!is.null(private$map)` — fan-out is driven entirely by the presence of `@maestroMap`.

### Step 2 — Tag parsing ✅

**`roxy_tag_parse.roxy_tag_maestroInputs`** detects `collect(...)` forms. Stores `list(inputs, is_collect)` in `x$val`. Plain inputs are stored as a character vector.

**`roxy_tag_parse.roxy_tag_maestroMap`** added. Splits on whitespace; empty value stores `".input"` (iterate over upstream return value directly).

### Step 3 — `build_schedule_entry()` validations and wiring ✅

- [x] Unpack `is_collect` / `inputs` from tag val
- [x] Parse `@maestroMap` expressions; abort on invalid R
- [x] Pass `is_collect`, `map` into `MaestroPipeline$new()`

### Step 4 — `validate_network()` in `MaestroPipelineList` ✅

- [x] `collect()` with fewer than two inputs where the single input is not a `@maestroMap` pipeline → `cli_abort()`

### Step 5 — `run_pipe()` in `MaestroPipelineList$run()` ✅

- [x] Fan-out (`get_is_map()`): `purrr::iwalk` scatter loop, all iterations on one `MaestroPipeline` object
- [x] Fan-in (`is_collect`): `private$resolve_collect_input()` centralises all readiness guards; inline guard in `run_pipe` + post-pass via `run_pending_collects()` for multicore

### Step 6 — Tests ✅

- [x] Tag parser tests
- [x] `build_schedule_entry()` success cases
- [x] `build_schedule_entry()` validation errors
- [x] `validate_network()` arity errors (`collect()` < 2 non-map inputs)
- [x] Fan-out execution (single-core + multicore)
- [x] Fan-in execution: simple, error cases, conditional, complex DAG (single-core + multicore)
- [x] Fork-join (fan-out → fan-in): happy path, partial error, full error (single-core + multicore)
- [x] Collect with downstream outputs — single-core fixture in place; multicore test in `test-multicore.R`

### Remaining / Deferred post-v1.2.0

- [ ] Cancel-on-first-failure for fan-out
- [ ] Aliasing in `collect()`
- [ ] Runtime warning when collect upstream is only partially scheduled
- [ ] CLI output improvements for fan-in/fan-out (docs and display)
- [ ] Label-by-input-value for branch identity in `get_status()` / `get_artifacts()`
