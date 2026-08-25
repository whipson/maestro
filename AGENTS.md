# maestro — Agent Instructions

## Project overview

**maestro** is an R package for scheduling and orchestrating data pipelines. Pipelines are
plain R functions annotated with roxygen2-style `@maestro*` tags; `build_schedule()` parses
those tags into a `MaestroSchedule` object that `run_schedule()` then executes.

## Key source files

| File | Purpose |
|------|---------|
| `R/roxy_maestro.R` | roxygen2 tag parsers (`roxy_tag_parse.*` methods) |
| `R/build_schedule_entry.R` | Registers tags, runs roxygen2 parsing, and calls `MaestroPipeline$new()` |
| `R/MaestroPipeline.R` | R6 class for a single pipeline — stores all tag values as private fields |
| `R/MaestroPipelineList.R` | R6 class for the full set of pipelines — DAG logic, cascade, validation |
| `R/build_schedule.R` | Orchestrates schedule construction; calls `apply_cascade()` after DAG validation |
| `R/maestro_tags.R` | User-facing documentation for every `@maestro*` tag |

## Maestro tag system

### How tags flow from source → schedule

1. **Parse** — `R/roxy_maestro.R` defines `roxy_tag_parse.roxy_tag_<TagName>()` for every
   `@maestro*` tag. These validate the raw string and return a typed value.

2. **Register** — `R/build_schedule_entry.R` maintains two named lists:
   - `maestro_tag_names` — single-valued tags (one occurrence per pipeline function).
   - `maestro_tag_names_mult` — multi-valued tags (can appear multiple times, e.g.
     `@maestroLabel`).

   Each list maps an internal field name (snake_case) to the roxygen2 tag string.

3. **Store** — `MaestroPipeline$initialize()` accepts a parameter for every field listed above
   and writes it to a private field. A public getter exposes each field.

4. **Consume** — `MaestroPipelineList` and downstream functions read fields via the public getters.

### Current tags

| Tag | List | Field name |
|-----|------|------------|
| `@maestroFrequency` | single | `frequency` |
| `@maestroStartTime` | single | `start_time` |
| `@maestroTz` | single | `tz` |
| `@maestroSkip` | single | `skip` |
| `@maestroLogLevel` | single | `log_level` |
| `@maestroHours` | single | `hours` |
| `@maestroDays` | single | `days` |
| `@maestroMonths` | single | `months` |
| `@maestroInputs` | single | `inputs` |
| `@maestroOutputs` | single | `outputs` |
| `@maestro` | single | `maestro` |
| `@maestroPriority` | single | `priority` |
| `@maestroFlags` | single | `flags` |
| `@maestroRunIf` | single | `run_if` |
| `@maestroMap` | single | `map` |
| `@maestroCascadeTags` | single | `cascade` |
| `@maestroLabel` | multi | `labels` |

## `@maestroCascadeTags` (added in v1.3.0)

### Purpose

Propagates selected metadata tags from a source pipeline to **all downstream pipelines** in the
DAG, avoiding repetition. Cascading is transitive — the entire downstream subgraph inherits, not
just direct children.

### Syntax

```r
#' @maestroCascadeTags label flags          # cascade specific tag types
#' @maestroCascadeTags                      # empty → cascade all three (label, flags, loglevel)
```

Accepted values (space-separated, case-insensitive): `label`, `flags`, `loglevel`.

### Merge / conflict rules

| Tag type | Behaviour |
|----------|-----------|
| `label` | Cascaded keys added only when the key is not already set locally (local wins). |
| `flags` | Union — cascaded flags not already present are appended. |
| `loglevel` | Applied only when the downstream pipeline's level is `"INFO"` (the default). A downstream that explicitly sets any other level keeps it. Cascading `INFO` is always a no-op. |

### Implementation touchpoints

- **`R/roxy_maestro.R`** — `roxy_tag_parse.roxy_tag_maestroCascadeTags()` parser.
- **`R/build_schedule_entry.R`** — `cascade = "maestroCascadeTags"` in `maestro_tag_names`.
- **`R/MaestroPipeline.R`** — `cascade` field + `get_cascade()` getter + `update_labels()`,
  `update_flags()`, `update_log_level()` mutators.
- **`R/MaestroPipelineList.R`** — `apply_cascade()` public method (BFS traversal).
- **`R/build_schedule.R`** — `apply_cascade()` called after `validate_network()`.
- **`R/maestro_tags.R`** — user-facing docs.
- **`tests/testthat/test-cascade.R`** + fixture directory `test_pipelines_cascade/`.

## Adding a new `@maestro*` tag — integration checklist

When a new metadata tag is introduced, **all of the following must be updated**:

1. **`R/roxy_maestro.R`** — Add `roxy_tag_parse.roxy_tag_<NewTag>()`. Validate the raw value
   and return a typed result. Emit `roxygen2::roxy_tag_warning()` for invalid input.

2. **`R/build_schedule_entry.R`** — Add an entry to `maestro_tag_names` (single-value) or
   `maestro_tag_names_mult` (multi-value). The key is the snake_case field name; the value is
   the roxygen2 tag string.

3. **`R/MaestroPipeline.R`** — Add:
   - A parameter to `initialize()` with a sensible default.
   - Assignment to a new `private$<field>` in `initialize()`.
   - A `private` field declaration.
   - A public `get_<field>()` getter.
   - Any public mutators needed (e.g. for cascade-style propagation).

4. **`R/MaestroPipelineList.R`** or **`R/build_schedule.R`** — Wire up any list-level logic
   that consumes the new field (e.g. sorting, filtering, propagation).

5. **`R/maestro_tags.R`** — Add user-facing documentation for the tag.

6. **`tests/testthat/`** — Add or extend fixture pipelines and write tests.

7. **`NEWS.md`** — Document under the appropriate version heading.

8. **`DESCRIPTION`** — Bump the version if releasing.

9. **`AGENTS.md`** (this file) — Add the new tag to the tags table and document any novel
   behaviour (like cascade semantics) if it's non-trivial.
