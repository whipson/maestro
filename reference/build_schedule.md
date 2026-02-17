# Build a schedule table

Builds a schedule data.frame for scheduling pipelines in
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
orchestrator requires a schedule table to determine which pipelines are
to run and when. Each row in a schedule table is a pipeline name and its
scheduling parameters such as its frequency.

The schedule table is mostly intended to be used by
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
immediately. In other words, it is not recommended to make changes to
it.

It is recommended to build the schedule from scratch on each run of the
orchestrator script rather than reusing or caching the schedule object.
This is because the schedule object precomputes and stores a limited set
of future run times for each pipeline.

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
