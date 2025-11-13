# Manually run a pipeline regardless of schedule

Instantly run a single pipeline from the schedule. This is useful for
testing purposes or if you want to just run something one-off.

## Usage

``` r
invoke(
  schedule,
  pipe_name,
  resources = list(),
  ...,
  quiet = TRUE,
  log_to_console = FALSE
)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

- pipe_name:

  name of a single pipe name from the schedule

- resources:

  named list of shared resources made available to pipelines as needed

- ...:

  other arguments passed to
  [`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)

- quiet:

  silence metrics to the console (default = `FALSE`). Note this does not
  affect messages generated from pipelines when `log_to_console = TRUE`.

- log_to_console:

  whether or not to include pipeline messages, warnings, errors to the
  console (default = `FALSE`) (see Logging & Console Output section)

## Value

invisible

## Details

Scheduling parameters such as the frequency, start time, and specifiers
are ignored. The pipeline will be run even if `maestroSkip` is present.
If the pipeline is a DAG pipeline, `invoke` will attempt to execute the
full DAG.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  invoke(schedule, "my_new_pipeline")
}
```
