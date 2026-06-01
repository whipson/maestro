# maestro 1.2.0 Release Notes

## Terminology Reference

| Pattern | Also known as | Description |
|---|---|---|
| Fan-out | Scatter, Broadcast, Map | 1 → N downstream executions |
| Fan-in | Gather, Merge, Join | N → 1 downstream execution |
| Fork-join | — | Fan-out immediately followed by fan-in |

---

## Feature 1: Dynamic Fan-Out (Scatter)

**Concept:** When an upstream pipeline returns a list or vector, a downstream declared with `@maestroInputs each(upstream)` executes once per element. All iterations are housed in a single `MaestroPipeline` object (consistent with the existing multi-execution model).

---

### Syntax

**Simple case** — upstream returns a vector/list; each element is one branch's `.input`:

```r
#' @maestroInputs each(upstream)
downstream <- function(.input) { ... }
```

**Complex case** — upstream returns a named list; `@maestroIterateOver` selects the iterator element:

```r
#' @maestroInputs each(upstream)
#' @maestroIterateOver .input$vec
downstream <- function(.input) { ... }
```

`@maestroIterateOver` also accepts named aliases and multiple selectors (pmap-style):

```r
# Named alias — .input inside branch is list(x = element)
#' @maestroIterateOver x = .input$vec

# Multi named (pmap-style) — .input is list(x = el_x, y = el_y)
#' @maestroIterateOver x = .input$ids y = .input$labels

# imap-style — names() is a valid expression
#' @maestroIterateOver val = .input$vec nm = names(.input$vec)
```

---

### `.input` shape contract inside the branch

| `@maestroIterateOver` form | `.input` shape |
|---|---|
| Absent (no tag) | Raw element of the upstream return value |
| Unnamed single selector | Raw element of the selected sub-value |
| Named single selector | Named list, e.g. `list(x = element)` |
| Named multi-selector | Named list, e.g. `list(x = el_x, y = el_y)` |

Unnamed multi-selector (>1 selector, none named) is not supported — `cli_abort()` at `build_schedule()` time.

**Note on aliases:** alias names control the names of list elements *inside* `.input`, not separate function parameters. The downstream function signature is always `function(.input)`. For named selectors the user accesses `.input$x`, `.input$y` etc.

---

### `each()` marker

- `each()` is **not** an exported function. It is a marker recognised only during tag parsing, analogous to `@maestroRunIf`.
- `roxy_tag_parse.roxy_tag_maestroInputs` detects `each()` and `collect()` forms before splitting, and stores `is_each`/`is_collect` flags alongside the inner pipeline name(s) in `x$val`. ✅
- Selector expressions in `@maestroIterateOver` are **not** validated at parse time — consistent with `@maestroRunIf`. Invalid expressions surface as runtime errors.

**Validation at `build_schedule()` time** (in `build_schedule_entry.R`):
- `@maestroIterateOver` without `each()` in `@maestroInputs` → `cli_abort()` ✅
- Unnamed multi-selector in `@maestroIterateOver` → `cli_abort()` ✅
- `each()` and `collect()` on the same `@maestroInputs` tag → `cli_abort()` (pending)
- Pipeline names inside `each()` / `collect()` must resolve to known pipelines → `cli_abort()` (occurs in `build_schedule()` / `MaestroPipelineList`, not `build_schedule_entry()`)

---

### Runtime execution

`run_pipe()` is a recursive closure defined inside `MaestroPipelineList$run()`. Currently it:
1. Calls `pipe$run(...)` once
2. Gets the return value via `pipe$get_returns()`
3. Looks up downstream names from the network: `out_names <- network$to[network$from == pipe$get_pipe_name()]`
4. Recurses into each downstream, passing `.input = .input`
5. Short-circuits on error/not-run status

For fan-out (`is_each = TRUE`), step 2-4 change: loop over `iterator`, calling `pipe$run(..., .input = iterator[[i]])` for each element. All iterations write into the same `MaestroPipeline` object distinguished by `internal_run_id`.

```r
eval_selector <- function(expr_str, upstream_result) {
  eval(parse(text = expr_str), envir = list(.input = upstream_result))
}

# No @maestroIterateOver — iterate over whole upstream result
iterator <- upstream_result

# Unnamed single selector
iterator <- eval_selector(".input$vec", upstream_result)
branch_input <- iterator[[i]]

# Named single or multi selector
iterators <- lapply(named_selectors, eval_selector, upstream_result = upstream_result)
# length parity validated here at run time
branch_input <- lapply(iterators, `[[`, i)  # named list preserved as .input
```

For fan-in (`is_collect = TRUE`), `run_pipe()` must accumulate results from all upstream executions before calling `pipe$run()` once. This cuts against the current depth-first recursive model and is the most complex architectural change — see implementation notes below.

**Branch identity** in `get_status()` / `get_artifacts()`: `downstream[1]`, `downstream[2]`, ...
Label-by-input-value deferred post-v1.2.0.

---

### Settled decisions

| Decision | Resolution |
|---|---|
| Marker name | `each()` |
| Real exported function? | No |
| Complex case syntax | `@maestroIterateOver` separate tag |
| Named alias syntax | `x = .input$vec` supported; controls element names inside `.input` |
| `.input` contract | Raw element (unnamed) or named list (named selectors) |
| Runtime architecture | Multiple executions on one `MaestroPipeline` object |
| Branch identity | `downstream[1]`, `downstream[2]`, ... |
| Error semantics | Continue on branch failure; all errors collected as normal |
| Cancel-on-first-failure | Deferred post-v1.2.0 |
| `@maestroRunIf` | Evaluated once per branch with that branch's `.input` |

---

## Feature 2: Fan-In (Gather/Merge)

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
#' @maestroInputs collect(upstream)  # upstream declared with each()
downstream <- function(.input) {
  # .input is an unnamed list of length n (one element per branch)
  # .input[[1]], .input[[2]], ...\n
}
```

---

### `.input` shape contract

| Case | `.input` shape |
|---|---|
| Static fan-in | Named list keyed by pipeline name |
| Dynamic fan-in (fork-join) | Unnamed list of length n |

---

### `collect()` marker

- `collect()` is **not** an exported function. It is a marker recognised only during tag parsing, consistent with `each()` and `@maestroRunIf`.
- Whether the upstream used `each()` or not is resolved at runtime — `collect()` on a non-`each()` upstream is valid (static fan-in).

**Validation at `build_schedule()` time:**
- Pipeline names inside `collect()` must resolve to known pipelines in the schedule → `cli_abort()`
- `collect()` and `each()` cannot both appear on the same `@maestroInputs` tag → `cli_abort()`

**Deferred:** aliasing in `collect()` (e.g. `collect(cust = upstream_customers, ord = upstream_orders)`) — not necessary since users can rename inside the function body. Deferred post-v1.2.0.

---

### Settled decisions

| Decision | Resolution |
|---|---|
| Marker name | `collect()` |
| Real exported function? | No |
| Static fan-in `.input` shape | Named list keyed by pipeline name |
| Dynamic fan-in `.input` shape | Unnamed list of length n |
| `collect()` on non-`each()` upstream | Valid — no build-time error |
| `collect()` + `each()` on same tag | Invalid → `cli_abort()` at build time |
| Aliasing in `collect()` | Not needed; deferred post-v1.2.0 |

---

### Scheduling constraint for collect

For a fan-in to actually execute, **all named upstream pipelines must be scheduled in the same orchestrator run**. If any upstream is not scheduled (wrong frequency, skipped, future start time, etc.), the collect node will wait indefinitely — it will never see all upstream results and will silently not run.

**Mitigation:** At runtime, before deferring or accumulating, check that every upstream named in `collect(...)` is actually scheduled (`pipe$get_is_scheduled()` or equivalent). If one or more are not scheduled, emit a warning and skip the downstream rather than silently hanging.

**Validation options (in priority order):**

1. **Runtime warning** — cheapest; warn when a collect node's upstream set is only partially scheduled in the current run. The downstream is skipped with a descriptive message.
2. **Build-time warning** — at `build_schedule()` time, flag collect nodes whose upstreams have mismatched frequencies or skip flags. Cannot catch time-based misses (e.g. `hourly` vs `daily`), so this is supplementary at best.

Decision: implement option 1 at minimum for v1.2.0. Option 2 deferred.

---

## Implementation Checklist

### Step 1 — `MaestroPipeline`: new fields ✅

Added to `initialize()` and private fields:
- `is_each` (logical, default `FALSE`)
- `is_collect` (logical, default `FALSE`)
- `iterate_over` (list of named `key = expr_string` pairs, or `NULL`)

Getters added: `get_is_each()`, `get_is_collect()`, `get_iterate_over()`.

### Step 2 — Tag parsing ✅

**`roxy_tag_parse.roxy_tag_maestroInputs`** extended to detect `each(...)` and `collect(...)` forms. Stores `list(inputs, is_each, is_collect)` in `x$val`.

**`roxy_tag_parse.roxy_tag_maestroIterateOver`** added. Stores `x$val <- x$raw` verbatim (consistent with `@maestroRunIf`).

### Step 3 — `build_schedule_entry()` validations and wiring

- [x] Unpack `is_each` / `is_collect` / `inputs` from new list val
- [x] Parse `@maestroIterateOver` raw string into named `key = expr_string` pairs
- [x] Abort if `@maestroIterateOver` present but `is_each = FALSE`
- [x] Abort if unnamed multi-selector in `@maestroIterateOver`
- [ ] Abort if `is_each` and `is_collect` both `TRUE` on same pipeline
- [x] Pass `is_each`, `is_collect`, `iterate_over` into `MaestroPipeline$new()`

### Step 4 — `run_pipe()` in `MaestroPipelineList$run()`

Fan-out (`is_each`): loop over iterator, run branch n times on same `MaestroPipeline` object.
Fan-in (`is_collect`): accumulate upstream results before single downstream execution. Most complex change — likely requires an accumulator pattern rather than pure depth-first recursion.

### Step 5 — Tests

Test file: `tests/testthat/test-fanout.R` — uses `withr::local_tempfile()` + `writeLines()` inline (no fixture files).

- [x] Tag parser tests (Steps 1 & 2)
- [x] `build_schedule_entry()` success cases
- [x] `build_schedule_entry()` validation errors
- [ ] `run_pipe()` fan-out execution
- [ ] `run_pipe()` fan-in execution
