# Class for a schedule of pipelines

Class for a schedule of pipelines

Class for a schedule of pipelines

## Public fields

- `PipelineList`:

  object of type MaestroPipelineList

## Methods

### Public methods

- [`MaestroSchedule$new()`](#method-MaestroSchedule-new)

- [`MaestroSchedule$print()`](#method-MaestroSchedule-print)

- [`MaestroSchedule$run()`](#method-MaestroSchedule-run)

- [`MaestroSchedule$get_schedule()`](#method-MaestroSchedule-get_schedule)

- [`MaestroSchedule$get_status()`](#method-MaestroSchedule-get_status)

- [`MaestroSchedule$get_artifacts()`](#method-MaestroSchedule-get_artifacts)

- [`MaestroSchedule$get_network()`](#method-MaestroSchedule-get_network)

- [`MaestroSchedule$get_flags()`](#method-MaestroSchedule-get_flags)

- [`MaestroSchedule$show_network()`](#method-MaestroSchedule-show_network)

- [`MaestroSchedule$get_run_sequence()`](#method-MaestroSchedule-get_run_sequence)

- [`MaestroSchedule$clone()`](#method-MaestroSchedule-clone)

------------------------------------------------------------------------

### Method `new()`

Create a MaestroSchedule object

#### Usage

    MaestroSchedule$new(Pipelines = NULL)

#### Arguments

- `Pipelines`:

  list of MaestroPipelines

#### Returns

MaestroSchedule

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the schedule object

#### Usage

    MaestroSchedule$print()

#### Returns

print

------------------------------------------------------------------------

### Method `run()`

Run a MaestroSchedule

#### Usage

    MaestroSchedule$run(..., quiet = FALSE, run_all = FALSE, n_show_next = 5)

#### Arguments

- `...`:

  arguments passed to MaestroPipelineList\$run

- `quiet`:

  whether or not to silence console messages

- `run_all`:

  run all pipelines regardless of the schedule (default is `FALSE`) -
  useful for testing.

- `n_show_next`:

  show the next n scheduled pipes

#### Returns

invisible

------------------------------------------------------------------------

### Method [`get_schedule()`](https://whipson.github.io/maestro/reference/get_schedule.md)

Get the schedule as a data.frame

#### Usage

    MaestroSchedule$get_schedule()

#### Returns

data.frame

------------------------------------------------------------------------

### Method [`get_status()`](https://whipson.github.io/maestro/reference/get_status.md)

Get status of the pipelines as a data.frame

#### Usage

    MaestroSchedule$get_status()

#### Returns

data.frame

------------------------------------------------------------------------

### Method [`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md)

Get artifacts (return values) from the pipelines

#### Usage

    MaestroSchedule$get_artifacts()

#### Returns

list

------------------------------------------------------------------------

### Method `get_network()`

Get the network structure of the pipelines as an edge list (will be
empty if there are no DAG pipelines)

#### Usage

    MaestroSchedule$get_network()

#### Returns

data.frame

------------------------------------------------------------------------

### Method [`get_flags()`](https://whipson.github.io/maestro/reference/get_flags.md)

Get all pipeline flags as a long data.frame

#### Usage

    MaestroSchedule$get_flags()

#### Returns

data.frame

------------------------------------------------------------------------

### Method [`show_network()`](https://whipson.github.io/maestro/reference/show_network.md)

Visualize the DAG relationships between pipelines in the schedule

#### Usage

    MaestroSchedule$show_network()

#### Returns

interactive visualization

------------------------------------------------------------------------

### Method [`get_run_sequence()`](https://whipson.github.io/maestro/reference/get_run_sequence.md)

Get full sequence of scheduled executions for all pipelines

#### Usage

    MaestroSchedule$get_run_sequence(
      n = NULL,
      min_datetime = NULL,
      max_datetime = NULL,
      include_only_primary = FALSE
    )

#### Arguments

- `n`:

  optional sequence limit

- `min_datetime`:

  optional minimum datetime

- `max_datetime`:

  optional maximum datetime

- `include_only_primary`:

  only primary pipelines are included (this are pipelines that are
  scheduled and not downstream nodes in a DAG)

#### Returns

data.frame

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MaestroSchedule$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)
}
```
