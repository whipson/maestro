# Copilot Instructions for `maestro`

## Project Overview

`maestro` is an R package providing a stateless pipeline orchestration framework. Users decorate R functions with **roxygen2-style `@maestro*` tags** to schedule them; a separate orchestrator script calls `build_schedule()` + `run_schedule()` to parse tags and invoke pipelines on a time-based cadence.

## Architecture

Three R6 classes form the core object model:

- **`MaestroPipeline`** (`R/MaestroPipeline.R`) — represents a single scheduled function parsed from a script. Holds scheduling parameters (frequency, start time, tz, hours, days, months), DAG wiring (inputs/outputs), and execution state (status, artifacts, logs).
- **`MaestroPipelineList`** (`R/MaestroPipelineList.R`) — an ordered collection of `MaestroPipeline` objects sorted by priority. Handles bulk operations (run, get_status, validate_network).
- **`MaestroSchedule`** (`R/MaestroSchedule.R`) — the top-level user-facing object returned by `build_schedule()`. Wraps a `MaestroPipelineList` and exposes `run()`, `get_status()`, `get_artifacts()`, `get_network()`, `show_network()`, `get_run_sequence()`.

### Data flow

```
pipelines/*.R  →  build_schedule()  →  MaestroSchedule
                     ↑ parses via roxygen2 tags (build_schedule_entry.R + roxy_maestro.R)
MaestroSchedule  →  run_schedule()  →  side effects + returns MaestroSchedule
```

Post-run diagnostics are accessed via helpers (`last_run_errors()`, `last_run_warnings()`, `last_run_messages()`, `last_build_errors()`) which read from the package-level environment `maestro_pkgenv` (`R/zzz.R`).

## Tag System

Tags are custom roxygen2 roclets defined in `R/roxy_maestro.R` and documented in `R/maestro_tags.R`. Each tag has a `roxy_tag_parse.*` S3 method that validates at parse time. Key tags:

| Tag | Default | Notes |
|---|---|---|
| `@maestroFrequency` | `1 day` | e.g. `hourly`, `2 weeks`, `3 months` |
| `@maestroStartTime` | `2024-01-01 00:00:00` | date, datetime, or `HH:MM:SS` time |
| `@maestroTz` | `UTC` | any `OlsonNames()` value |
| `@maestroLogLevel` | `INFO` | `ERROR`, `WARN`, `INFO` |
| `@maestroInputs` / `@maestroOutputs` | — | DAG wiring; receiving pipeline needs `.input` param |
| `@maestroSkip` | — | flag only, no value |
| `@maestroPriority` | `Inf` | lower integer = higher priority |
| `@maestroFlags` | — | space-separated arbitrary labels |
| `@maestroRunIf` | — | R expression evaluated to a single `TRUE`/`FALSE` (see below) |
| `@maestro` | — | generic tag to include pipeline with all defaults |

**Pipeline scripts must not contain top-level code** (only function definitions). `build_schedule_entry()` uses `roxygen2::parse_file()` which executes the script in a fresh environment—loose code will error.

**Function names must be unique** across all files in `pipeline_dir`.

## `@maestroRunIf` — Three Evaluation Contexts

The expression is evaluated at run time; the pipeline is skipped (not errored) when it returns `FALSE`.

1. **Inline expression** — any R code returning a single boolean:
   ```r
   #' @maestroRunIf sample(c(TRUE, FALSE), size = 1)
   ```

2. **DAG `.input`** — the upstream return value is available as `.input`; useful for guarding against empty/bad data:
   ```r
   #' @maestroInputs extract_flights
   #' @maestroRunIf
   #' is.data.frame(.input) && nrow(.input) > 0
   transform_flights <- function(.input) { ... }
   ```

3. **Orchestrator resource** — a named value from `run_schedule(..., resources = list(...))` is referenced by name:
   ```r
   #' @maestroRunIf prod          # TRUE only when resources = list(prod = TRUE)
   process_payments <- function() { ... }
   ```

## DAG Pipelines

A downstream pipeline declares `@maestroInputs upstream_fn` and accepts `.input` as a required parameter. The return value of the upstream pipeline is passed as `.input`. An error in an upstream node stops downstream execution.

```r
#' @maestroFrequency daily
extract <- function() { mtcars }

#' @maestroInputs extract
transform <- function(.input) { dplyr::mutate(.input, hp2 = hp^2) }
```

## Developer Workflows

### Testing

```r
devtools::test()              # run all tests
devtools::test_active_file()  # test current file
```

Tests use `testthat` (edition 3). Fixture pipeline scripts live under `tests/testthat/test_pipelines*/` directories—use `test_path()` to reference them. Snapshot tests (`expect_snapshot()`) are used for status outputs; update with `testthat::snapshot_update()`.

### Build / Check

```r
devtools::load_all()   # load package
devtools::check()      # full R CMD check
devtools::document()   # regenerate docs (runs roxygen2)
```

### Adding a new `@maestro*` tag

1. Add `roxy_tag_parse.roxy_tag_maestroXxx` S3 method in `R/roxy_maestro.R`.
2. Add the tag name to `maestro_tag_names` list in `build_schedule_entry()`.
3. Pass the parsed value into `MaestroPipeline$new()` in `build_schedule_entry()`.
4. Add the parameter to `MaestroPipeline$initialize()` and store in a private field.
5. Document in `R/maestro_tags.R`.

## Conventions

- **`%n%`** (null-coalescing operator in `R/utils.R`) is used pervasively: `val %n% default` returns `default` when `val` is `NA` or `NULL`.
- CLI output uses `cli` package throughout; errors via `cli::cli_abort()`, warnings via `cli::cli_warn()`.
- Iteration uses `purrr`; `withCallingHandlers(..., purrr_error_indexed = ...)` pattern is used to surface indexed purrr errors cleanly.
- Multicore execution (`cores > 1`) requires `furrr` + `future::plan(future::multisession)` in the orchestrator; the package checks for `furrr` availability at runtime.
- `R/zzz.R` defines `maestro_pkgenv`—the only persistent mutable state in the package (last run errors/warnings/messages).
