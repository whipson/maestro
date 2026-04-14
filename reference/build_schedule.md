# Build a schedule

Builds a `MaestroSchedule` object for use in
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).

## Usage

``` r
build_schedule(pipeline_dir = "./pipelines", quiet = FALSE)
```

## Arguments

- pipeline_dir:

  path to directory containing the pipeline scripts

- quiet:

  silence metrics to the console (default = `FALSE`)

## Value

MaestroSchedule

## Details

This function parses the maestro tags of functions located in
`pipeline_dir` which is conventionally called 'pipelines'. An
orchestrator requires a `MaestroSchedule` to determine which pipelines
are to run and when. Each pipeline in the schedule is a parsed function
and its scheduling parameters such as its frequency.

The `MaestroSchedule` is mostly intended to be passed directly to
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).
In other words, it is not recommended to make changes to it.

## Examples

``` r
# Creating a temporary directory for demo purposes! In practice, just
# create a 'pipelines' directory at the project level.

if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  build_schedule(pipeline_dir = pipeline_dir)
}
```
