# Suggest orchestrator frequency based on a schedule

Suggests a frequency to run the orchestrator based on the frequencies of
the pipelines in a schedule.

## Usage

``` r
suggest_orch_frequency(
  schedule,
  check_datetime = lubridate::now(tzone = "UTC")
)
```

## Arguments

- schedule:

  MaestroSchedule object created by
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

- check_datetime:

  datetime against which to check the running of pipelines (default is
  current system time in UTC)

## Value

frequency string

## Details

This function attempts to find the smallest interval of time between all
pipelines. If the smallest interval is less than 15 minutes, it just
uses the smallest interval.

Note this function is intended to be used interactively when deciding
how often to schedule the orchestrator. Programmatic use is not
recommended.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)
  suggest_orch_frequency(schedule)
}
```
