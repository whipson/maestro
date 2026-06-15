# Class for a schedule of pipelines

Class for a schedule of pipelines

## Public fields

- `PipelineList`:

  object of type MaestroPipelineList

## Methods

### Public methods

- [`MaestroSchedule$new()`](#method-MaestroSchedule-initialize)

- [`MaestroSchedule$print()`](#method-MaestroSchedule-print)

- [`MaestroSchedule$run()`](#method-MaestroSchedule-run)

- [`MaestroSchedule$get_schedule()`](#method-MaestroSchedule-get_schedule)

- [`MaestroSchedule$get_status()`](#method-MaestroSchedule-get_status)

- [`MaestroSchedule$get_artifacts()`](#method-MaestroSchedule-get_artifacts)

- [`MaestroSchedule$get_network()`](#method-MaestroSchedule-get_network)

- [`MaestroSchedule$get_flags()`](#method-MaestroSchedule-get_flags)

- [`MaestroSchedule$get_labels()`](#method-MaestroSchedule-get_labels)

- [`MaestroSchedule$get_run_sequence()`](#method-MaestroSchedule-get_run_sequence)

- [`MaestroSchedule$clone()`](#method-MaestroSchedule-clone)

------------------------------------------------------------------------

### `MaestroSchedule$new()`

Create a MaestroSchedule object

#### Usage

    MaestroSchedule$new(Pipelines = NULL)

#### Arguments

- `Pipelines`:

  list of MaestroPipelines

#### Returns

MaestroSchedule

------------------------------------------------------------------------

### `MaestroSchedule$print()`

Print the schedule object

#### Usage

    MaestroSchedule$print()

#### Returns

print

------------------------------------------------------------------------

### `MaestroSchedule$run()`

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

### `MaestroSchedule$get_schedule()`

Get the schedule as a data.frame

#### Usage

    MaestroSchedule$get_schedule()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$get_status()`

Get status of the pipelines as a data.frame

#### Usage

    MaestroSchedule$get_status()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$get_artifacts()`

Get artifacts (return values) from the pipelines

#### Usage

    MaestroSchedule$get_artifacts()

#### Returns

list

------------------------------------------------------------------------

### `MaestroSchedule$get_network()`

Get the network structure of the pipelines as an edge list (will be
empty if there are no DAG pipelines)

#### Usage

    MaestroSchedule$get_network()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$get_flags()`

Get all pipeline flags as a long data.frame

#### Usage

    MaestroSchedule$get_flags()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$get_labels()`

Get all pipeline labels as a data.frame

#### Usage

    MaestroSchedule$get_labels()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$get_run_sequence()`

Get full sequence of scheduled executions for all pipelines

#### Usage

    MaestroSchedule$get_run_sequence(
      n = NULL,
      min_datetime = NULL,
      max_datetime = NULL,
      include_only_primary = FALSE,
      include_skipped = TRUE
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

- `include_skipped`:

  whether to include pipelines tagged with `@maestroSkip` (default
  `TRUE` for backwards compatibility)

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroSchedule$clone()`

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
