# Get the schedule from a MaestroSchedule object

A schedule is represented as a table where each row is a pipeline and
the columns contain scheduling parameters such as the frequency and
start time.

## Usage

``` r
get_schedule(schedule)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

## Value

data.frame

## Details

The schedule table is used internally in a MaestroSchedule object but
can be accessed using this function or accessing the R6 method of the
MaestroSchedule object.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  get_schedule(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_schedule()
}
```
