# Get metrics recorded by pipelines in a MaestroSchedule object

Creates a long data.frame of metrics recorded via
[`update_metric()`](https://whipson.github.io/maestro/reference/update_metric.md)
for all pipelines in the schedule, across all runs.

## Usage

``` r
get_metrics(schedule)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

## Value

data.frame with columns `pipe_name`, `run_id`, `metric`, `value`
(numeric)

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  schedule <- run_schedule(
    schedule,
    orch_frequency = "1 day",
    quiet = TRUE
  )

  get_metrics(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_metrics()
}
```
