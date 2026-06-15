# Get the labels of pipelines in a MaestroSchedule object

Creates a data.frame of labels for all labelled pipelines in the
schedule.

## Usage

``` r
get_labels(schedule)
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

  get_labels(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_labels()
}
```
