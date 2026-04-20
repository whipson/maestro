# Copilot Instructions for maestro

## Project Overview

`maestro` is an R package providing a stateless pipeline orchestration
framework. Users decorate R functions with **roxygen2-style `@maestro*`
tags** to schedule them; a separate orchestrator script calls
[`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md) +
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
to parse tags and invoke pipelines on a time-based cadence.

## Architecture

Three R6 classes form the core object model:

- **`MaestroPipeline`** (`R/MaestroPipeline.R`) — represents a single
  scheduled function parsed from a script. Holds scheduling parameters
  (frequency, start time, tz, hours, days, months), DAG wiring
  (inputs/outputs), and execution state (status, artifacts, logs).
- **`MaestroPipelineList`** (`R/MaestroPipelineList.R`) — an ordered
  collection of `MaestroPipeline` objects sorted by priority. Handles
  bulk operations (run, get_status, validate_network).
- **`MaestroSchedule`** (`R/MaestroSchedule.R`) — the top-level
  user-facing object returned by
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md).
  Wraps a `MaestroPipelineList` and exposes `run()`,
  [`get_status()`](https://whipson.github.io/maestro/reference/get_status.md),
  [`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md),
  [`get_network()`](https://whipson.github.io/maestro/reference/get_network.md),
  [`show_network()`](https://whipson.github.io/maestro/reference/show_network.md),
  [`get_run_sequence()`](https://whipson.github.io/maestro/reference/get_run_sequence.md).

### Data flow

    pipelines/*.R  →  build_schedule()  →  MaestroSchedule
                         ↑ parses via roxygen2 tags (build_schedule_entry.R + roxy_maestro.R)
    MaestroSchedule  →  run_schedule()  →  side effects + returns MaestroSchedule

Post-run diagnostics are accessed via helpers
([`last_run_errors()`](https://whipson.github.io/maestro/reference/last_run_errors.md),
[`last_run_warnings()`](https://whipson.github.io/maestro/reference/last_run_warnings.md),
[`last_run_messages()`](https://whipson.github.io/maestro/reference/last_run_messages.md),
[`last_build_errors()`](https://whipson.github.io/maestro/reference/last_build_errors.md))
which read from the package-level environment `maestro_pkgenv`
(`R/zzz.R`).

## Scheduling Internals

There are two distinct scheduling concerns with different performance
characteristics:

**Operational** — determines whether a pipeline should run right now and
what its next run time is. This is on the critical path every time
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
is called in production. Implemented in
`MaestroPipeline$check_timeliness()`.

**Observable** — generates long-horizon sequences of run times for
user-facing inspection
([`get_run_sequence()`](https://whipson.github.io/maestro/reference/get_run_sequence.md),
[`get_slot_usage()`](https://whipson.github.io/maestro/reference/get_slot_usage.md)).
Called interactively and infrequently.

### No stored run sequences

`MaestroPipeline` objects do **not** store a pre-computed run sequence.
There is no `run_sequence` private field. This keeps serialised
`MaestroSchedule` objects small.

### `check_timeliness()` — pure arithmetic

The operational check is done entirely with arithmetic via
[`.prev_on_cycle()`](https://whipson.github.io/maestro/reference/dot-prev_on_cycle.md)
(in `R/utils.R`), with no sequence generation:

1.  Call `.prev_on_cycle(start_time, current = check_datetime, ...)` to
    get the most recent cycle point strictly before `check_datetime`.
2.  Also compute `current_cycle = prev + one_step` (the cycle point at
    or just after `check_datetime`).
3.  Round both candidates to the orchestrator frequency and compare to
    `check_datetime_round`. Whichever matches is the `matched_slot`.
4.  Apply sub-day/calendar filters (`hours`, `days_of_week`,
    `days_of_month`, `months`) to `matched_slot`. If it passes, the
    pipeline is scheduled now.
5.  Compute `next_run` by calling
    [`get_pipeline_run_sequence()`](https://whipson.github.io/maestro/reference/get_pipeline_run_sequence.md)
    starting from `current_cycle` and taking the first result.

The epsilon behaviour of
[`.prev_on_cycle()`](https://whipson.github.io/maestro/reference/dot-prev_on_cycle.md)
(returns strictly-before, never equal) is intentional. When
`check_datetime` lands exactly on a cycle point,
[`.prev_on_cycle()`](https://whipson.github.io/maestro/reference/dot-prev_on_cycle.md)
returns the previous slot; the method detects this by nudging
`check_datetime + 1 second` and checking if the result equals
`check_datetime`.

### `.prev_on_cycle(start, current, amount, unit)`

Located in `R/utils.R`. Returns the most recent cycle point strictly
before `current`, given a repeating schedule anchored at `start` with
step `amount`/`unit`. Returns `NA` when `current <= start`. Supports
both `POSIXct` (all units) and `Date` (day and above only). Tests are in
`tests/testthat/test-prev_on_cycle.R`.

### Observable run sequences — generated on demand

`MaestroPipeline$get_run_sequence()` and the package-level
[`get_run_sequence()`](https://whipson.github.io/maestro/reference/get_run_sequence.md)
/
[`get_slot_usage()`](https://whipson.github.io/maestro/reference/get_slot_usage.md)
functions generate sequences on demand by calling
[`get_pipeline_run_sequence()`](https://whipson.github.io/maestro/reference/get_pipeline_run_sequence.md)
(in `R/get_run_sequence.R`). Nothing is stored between calls.

## Tag System

Tags are custom roxygen2 roclets defined in `R/roxy_maestro.R` and
documented in `R/maestro_tags.R`. Each tag has a `roxy_tag_parse.*` S3
method that validates at parse time. Key tags:

| Tag                                  | Default               | Notes                                                             |
|--------------------------------------|-----------------------|-------------------------------------------------------------------|
| `@maestroFrequency`                  | `1 day`               | e.g. `hourly`, `2 weeks`, `3 months`                              |
| `@maestroStartTime`                  | `2024-01-01 00:00:00` | date, datetime, or `HH:MM:SS` time                                |
| `@maestroTz`                         | `UTC`                 | any [`OlsonNames()`](https://rdrr.io/r/base/timezones.html) value |
| `@maestroLogLevel`                   | `INFO`                | `ERROR`, `WARN`, `INFO`                                           |
| `@maestroInputs` / `@maestroOutputs` | —                     | DAG wiring; receiving pipeline needs `.input` param               |
| `@maestroSkip`                       | —                     | flag only, no value                                               |
| `@maestroPriority`                   | `Inf`                 | lower integer = higher priority                                   |
| `@maestroFlags`                      | —                     | space-separated arbitrary labels                                  |
| `@maestroRunIf`                      | —                     | R expression evaluated to a single `TRUE`/`FALSE` (see below)     |
| `@maestro`                           | —                     | generic tag to include pipeline with all defaults                 |

**Pipeline scripts must not contain top-level code** (only function
definitions).
[`build_schedule_entry()`](https://whipson.github.io/maestro/reference/build_schedule_entry.md)
uses
[`roxygen2::parse_file()`](https://roxygen2.r-lib.org/reference/parse_package.html)
which executes the script in a fresh environment—loose code will error.

**Function names must be unique** across all files in `pipeline_dir`.

## `@maestroRunIf` — Three Evaluation Contexts

The expression is evaluated at run time; the pipeline is skipped (not
errored) when it returns `FALSE`.

1.  **Inline expression** — any R code returning a single boolean:

    ``` r
    #' @maestroRunIf sample(c(TRUE, FALSE), size = 1)
    ```

2.  **DAG `.input`** — the upstream return value is available as
    `.input`; useful for guarding against empty/bad data:

    ``` r
    #' @maestroInputs extract_flights
    #' @maestroRunIf
    #' is.data.frame(.input) && nrow(.input) > 0
    transform_flights <- function(.input) { ... }
    ```

3.  **Orchestrator resource** — a named value from
    `run_schedule(..., resources = list(...))` is referenced by name:

    ``` r
    #' @maestroRunIf prod          # TRUE only when resources = list(prod = TRUE)
    process_payments <- function() { ... }
    ```

## DAG Pipelines

A downstream pipeline declares `@maestroInputs upstream_fn` and accepts
`.input` as a required parameter. The return value of the upstream
pipeline is passed as `.input`. An error in an upstream node stops
downstream execution.

``` r
#' @maestroFrequency daily
extract <- function() { mtcars }

#' @maestroInputs extract
transform <- function(.input) { dplyr::mutate(.input, hp2 = hp^2) }
```

## Key User-Facing Functions

Most schedule-level operations have both a **standalone function** and
an equivalent **R6 method** on `MaestroSchedule`. Always implement the
R6 method first; the standalone is a thin wrapper that validates the
class then delegates:

``` r
get_flags(schedule)       # standalone
schedule$get_flags()      # R6 equivalent — same result
```

This dual API applies to:
[`get_status()`](https://whipson.github.io/maestro/reference/get_status.md),
[`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md),
[`get_schedule()`](https://whipson.github.io/maestro/reference/get_schedule.md),
[`get_flags()`](https://whipson.github.io/maestro/reference/get_flags.md),
[`get_network()`](https://whipson.github.io/maestro/reference/get_network.md),
[`show_network()`](https://whipson.github.io/maestro/reference/show_network.md),
[`get_run_sequence()`](https://whipson.github.io/maestro/reference/get_run_sequence.md).

### `invoke()` — ad-hoc single pipeline runs

`invoke(schedule, pipe_name, resources = list(), ...)` runs one named
pipeline immediately, ignoring its schedule and `@maestroSkip`. Used for
testing and one-off execution. Pipeline arguments are still passed via
`resources`. If a DAG pipeline is invoked, its full upstream chain is
attempted.

### `run_schedule()` testing shortcuts

- `run_all = TRUE` — runs every non-skipped pipeline regardless of
  schedule; `@maestroRunIf` conditions still apply.
- `log_to_file = TRUE` (or a file path string) — appends to
  `maestro.log` (or the given path); file is purged when it exceeds
  `log_file_max_bytes` (default 1 MB). Prefer `log_to_file` over
  `log_to_console` in multicore mode (`cores > 1`), since
  `log_to_console` does not work with `furrr`.

## Developer Workflows

### Testing

``` r
devtools::test()              # run all tests
devtools::test_active_file()  # test current file
```

Tests use `testthat` (edition 3). Fixture pipeline scripts live under
`tests/testthat/test_pipelines*/` directories—use `test_path()` to
reference them. Snapshot tests (`expect_snapshot()`) are used for status
outputs; update with `testthat::snapshot_update()`.

### Build / Check

``` r
devtools::load_all()   # load package
devtools::check()      # full R CMD check
devtools::document()   # regenerate docs (runs roxygen2)
```

### Adding a new `@maestro*` tag

1.  Add `roxy_tag_parse.roxy_tag_maestroXxx` S3 method in
    `R/roxy_maestro.R`.
2.  Add the tag name to `maestro_tag_names` list in
    [`build_schedule_entry()`](https://whipson.github.io/maestro/reference/build_schedule_entry.md).
3.  Pass the parsed value into `MaestroPipeline$new()` in
    [`build_schedule_entry()`](https://whipson.github.io/maestro/reference/build_schedule_entry.md).
4.  Add the parameter to `MaestroPipeline$initialize()` and store in a
    private field.
5.  Document in `R/maestro_tags.R`.

## Conventions

- **`%n%`** (null-coalescing operator in `R/utils.R`) is used
  pervasively: `val %n% default` returns `default` when `val` is `NA` or
  `NULL`.
- CLI output uses `cli` package throughout; errors via
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
  warnings via
  [`cli::cli_warn()`](https://cli.r-lib.org/reference/cli_abort.html).
  Structured log file output uses the `logger` package (in Imports).
- Iteration uses `purrr`;
  `withCallingHandlers(..., purrr_error_indexed = ...)` pattern is used
  to surface indexed purrr errors cleanly.
- Multicore execution (`cores > 1`) requires `furrr` +
  `future::plan(future::multisession)` in the orchestrator; the package
  checks for `furrr` availability at runtime.
- `R/zzz.R` defines `maestro_pkgenv`—the only persistent mutable state
  in the package (last run errors/warnings/messages).
- **[`suggest_orch_frequency()`](https://whipson.github.io/maestro/reference/suggest_orch_frequency.md)
  is deprecated** as of v1.1.0 and may be removed. Do not use it in new
  code.
