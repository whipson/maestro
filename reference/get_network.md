# Get the network structure of pipelines in a MaestroSchedule object

Returns the pipeline dependency structure as an edge list data.frame.
Each row represents a directed dependency between two pipelines. The
result will be empty if there are no DAG pipelines in the schedule.

## Usage

``` r
get_network(schedule)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

## Value

data.frame with columns `from` and `to`

## See also

[`show_network()`](https://whipson.github.io/maestro/reference/show_network.md)
which is deprecated in favour of this function.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  get_network(schedule)

  # Alternatively, use the underlying R6 method
  schedule$get_network()
}
```
