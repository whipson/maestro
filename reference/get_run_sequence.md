# Get the run sequence of a schedule

Retrieves the scheduled run times for a given schedule, with optional
filtering by number of runs and datetime range.

## Usage

``` r
get_run_sequence(
  schedule,
  n = NULL,
  min_datetime = NULL,
  max_datetime = NULL,
  include_only_primary = FALSE
)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

- n:

  Optional positive integer. If specified, returns only the first `n`
  runs for each pipeline.

- min_datetime:

  Optional minimum datetime filter. Can be a lubridate::Date or
  lubridate::POSIXct object. If specified, only returns runs scheduled
  at or after this datetime.

- max_datetime:

  Optional maximum datetime filter. Can be a lubridate::Date or
  lubridate::POSIXct object. If specified, only returns runs scheduled
  at or before this datetime.

- include_only_primary:

  only primary pipelines are included (this are pipelines that are
  scheduled and not downstream nodes in a DAG)

## Value

A vector of datetime values representing the scheduled run times.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  get_run_sequence(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_run_sequence()
}
```
