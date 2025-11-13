# Get the flags of pipelines in a MaestroSchedule object

Creates a long data.frame where each row is a flag for each pipeline.

## Usage

``` r
get_flags(schedule)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

## Value

data.frame

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  get_flags(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_flags()
}
```
