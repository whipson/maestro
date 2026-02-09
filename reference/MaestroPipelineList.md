# Class for a list of MaestroPipelines A MaestroPipelineList is created when there are multiple maestro pipelines in a single script

Class for a list of MaestroPipelines A MaestroPipelineList is created
when there are multiple maestro pipelines in a single script

Class for a list of MaestroPipelines A MaestroPipelineList is created
when there are multiple maestro pipelines in a single script

## Public fields

- `MaestroPipelines`:

  list of pipelines

- `n_pipelines`:

  number of pipelines in the list

## Methods

### Public methods

- [`MaestroPipelineList$new()`](#method-MaestroPipelineList-new)

- [`MaestroPipelineList$print()`](#method-MaestroPipelineList-print)

- [`MaestroPipelineList$add_pipelines()`](#method-MaestroPipelineList-add_pipelines)

- [`MaestroPipelineList$update_pipelines()`](#method-MaestroPipelineList-update_pipelines)

- [`MaestroPipelineList$get_pipe_names()`](#method-MaestroPipelineList-get_pipe_names)

- [`MaestroPipelineList$get_pipe_by_name()`](#method-MaestroPipelineList-get_pipe_by_name)

- [`MaestroPipelineList$get_pipes_by_name()`](#method-MaestroPipelineList-get_pipes_by_name)

- [`MaestroPipelineList$get_priorities()`](#method-MaestroPipelineList-get_priorities)

- [`MaestroPipelineList$get_schedule()`](#method-MaestroPipelineList-get_schedule)

- [`MaestroPipelineList$get_timely_pipelines()`](#method-MaestroPipelineList-get_timely_pipelines)

- [`MaestroPipelineList$get_primary_pipes()`](#method-MaestroPipelineList-get_primary_pipes)

- [`MaestroPipelineList$check_timeliness()`](#method-MaestroPipelineList-check_timeliness)

- [`MaestroPipelineList$get_status()`](#method-MaestroPipelineList-get_status)

- [`MaestroPipelineList$get_errors()`](#method-MaestroPipelineList-get_errors)

- [`MaestroPipelineList$get_warnings()`](#method-MaestroPipelineList-get_warnings)

- [`MaestroPipelineList$get_messages()`](#method-MaestroPipelineList-get_messages)

- [`MaestroPipelineList$get_artifacts()`](#method-MaestroPipelineList-get_artifacts)

- [`MaestroPipelineList$get_run_sequences()`](#method-MaestroPipelineList-get_run_sequences)

- [`MaestroPipelineList$get_flags()`](#method-MaestroPipelineList-get_flags)

- [`MaestroPipelineList$get_network()`](#method-MaestroPipelineList-get_network)

- [`MaestroPipelineList$validate_network()`](#method-MaestroPipelineList-validate_network)

- [`MaestroPipelineList$run()`](#method-MaestroPipelineList-run)

- [`MaestroPipelineList$reset_pipelines()`](#method-MaestroPipelineList-reset_pipelines)

- [`MaestroPipelineList$clone()`](#method-MaestroPipelineList-clone)

------------------------------------------------------------------------

### Method `new()`

Create a MaestroPipelineList object

#### Usage

    MaestroPipelineList$new(MaestroPipelines = list(), network = NULL)

#### Arguments

- `MaestroPipelines`:

  list of MaestroPipelines

- `network`:

  initialize a network

#### Returns

MaestroPipelineList

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Print the MaestroPipelineList

#### Usage

    MaestroPipelineList$print()

#### Returns

print

------------------------------------------------------------------------

### Method `add_pipelines()`

Add pipelines to the list

#### Usage

    MaestroPipelineList$add_pipelines(MaestroPipelines = NULL)

#### Arguments

- `MaestroPipelines`:

  list of MaestroPipelines

#### Returns

invisible

------------------------------------------------------------------------

### Method `update_pipelines()`

Update pipelines in a list

#### Usage

    MaestroPipelineList$update_pipelines(MaestroPipelines = NULL)

#### Arguments

- `MaestroPipelines`:

  list of MaestroPipelines

#### Returns

invisible

------------------------------------------------------------------------

### Method `get_pipe_names()`

Get names of the pipelines in the list arranged by priority

#### Usage

    MaestroPipelineList$get_pipe_names()

#### Returns

character

------------------------------------------------------------------------

### Method `get_pipe_by_name()`

Get a MaestroPipeline by its name

#### Usage

    MaestroPipelineList$get_pipe_by_name(pipe_name)

#### Arguments

- `pipe_name`:

  name of the pipeline

#### Returns

MaestroPipeline

------------------------------------------------------------------------

### Method `get_pipes_by_name()`

Get a MaestroPipelineList with selected pipelines

#### Usage

    MaestroPipelineList$get_pipes_by_name(pipe_names)

#### Arguments

- `pipe_names`:

  names of the pipelines

#### Returns

MaestroPipelineList

------------------------------------------------------------------------

### Method `get_priorities()`

Get priorities

#### Usage

    MaestroPipelineList$get_priorities()

#### Returns

numeric

------------------------------------------------------------------------

### Method [`get_schedule()`](https://whipson.github.io/maestro/reference/get_schedule.md)

Get the schedule as a data.frame

#### Usage

    MaestroPipelineList$get_schedule()

#### Returns

data.frame

------------------------------------------------------------------------

### Method `get_timely_pipelines()`

Get a new MaestroPipelineList containing only those pipelines scheduled
to run

#### Usage

    MaestroPipelineList$get_timely_pipelines(...)

#### Arguments

- `...`:

  arguments passed to self\$check_timeliness

#### Returns

MaestroPipelineList

------------------------------------------------------------------------

### Method `get_primary_pipes()`

Get pipelines that are primary (i.e., don't have an inputting pipeline)

#### Usage

    MaestroPipelineList$get_primary_pipes()

#### Returns

list of MaestroPipelines

------------------------------------------------------------------------

### Method `check_timeliness()`

Check whether pipelines in the list are scheduled to run based on
orchestrator frequency and current time

#### Usage

    MaestroPipelineList$check_timeliness(...)

#### Arguments

- `...`:

  arguments passed to self\$check_timeliness

#### Returns

logical

------------------------------------------------------------------------

### Method [`get_status()`](https://whipson.github.io/maestro/reference/get_status.md)

Get status of the pipelines as a data.frame

#### Usage

    MaestroPipelineList$get_status()

#### Returns

data.frame

------------------------------------------------------------------------

### Method `get_errors()`

Get list of errors from the pipelines

#### Usage

    MaestroPipelineList$get_errors()

#### Returns

list

------------------------------------------------------------------------

### Method `get_warnings()`

Get list of warnings from the pipelines

#### Usage

    MaestroPipelineList$get_warnings()

#### Returns

list

------------------------------------------------------------------------

### Method `get_messages()`

Get list of messages from the pipelines

#### Usage

    MaestroPipelineList$get_messages()

#### Returns

list

------------------------------------------------------------------------

### Method [`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md)

Get artifacts (return values) from the pipelines

#### Usage

    MaestroPipelineList$get_artifacts()

#### Returns

list

------------------------------------------------------------------------

### Method `get_run_sequences()`

Get run sequences from the pipelines

#### Usage

    MaestroPipelineList$get_run_sequences(
      n = NULL,
      min_datetime = NULL,
      max_datetime = NULL
    )

#### Arguments

- `n`:

  optional sequence limit

- `min_datetime`:

  optional minimum datetime

- `max_datetime`:

  optional maximum datetime

#### Returns

list

------------------------------------------------------------------------

### Method [`get_flags()`](https://whipson.github.io/maestro/reference/get_flags.md)

Get the flags of the pipelines as a named list

#### Usage

    MaestroPipelineList$get_flags()

#### Returns

list

------------------------------------------------------------------------

### Method `get_network()`

Get the network structure as a edge list

#### Usage

    MaestroPipelineList$get_network()

#### Returns

data.frame

------------------------------------------------------------------------

### Method `validate_network()`

Validates whether all inputs and outputs exist and that the network is a
valid DAG

#### Usage

    MaestroPipelineList$validate_network()

#### Returns

warning or invisible

------------------------------------------------------------------------

### Method `run()`

Runs all the pipelines in the list

#### Usage

    MaestroPipelineList$run(..., cores = 1L, pipes_to_run = NULL)

#### Arguments

- `...`:

  arguments passed to MaestroPipeline\$run

- `cores`:

  if using multicore number of cores to run in (uses `furrr`)

- `pipes_to_run`:

  an optional vector of pipe names to run. If `NULL` defaults to all
  primary pipelines

#### Returns

invisible

------------------------------------------------------------------------

### Method `reset_pipelines()`

Resets the run time attributes

#### Usage

    MaestroPipelineList$reset_pipelines()

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MaestroPipelineList$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
