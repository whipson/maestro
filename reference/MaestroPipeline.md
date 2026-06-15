# Class for an individual maestro pipeline A pipeline is defined as a single R script with a schedule or input

Class for an individual maestro pipeline A pipeline is defined as a
single R script with a schedule or input

## Methods

### Public methods

- [`MaestroPipeline$new()`](#method-MaestroPipeline-initialize)

- [`MaestroPipeline$print()`](#method-MaestroPipeline-print)

- [`MaestroPipeline$run()`](#method-MaestroPipeline-run)

- [`MaestroPipeline$get_pipe_name()`](#method-MaestroPipeline-get_pipe_name)

- [`MaestroPipeline$get_frequency_nunits()`](#method-MaestroPipeline-get_frequency_nunits)

- [`MaestroPipeline$get_schedule()`](#method-MaestroPipeline-get_schedule)

- [`MaestroPipeline$check_timeliness()`](#method-MaestroPipeline-check_timeliness)

- [`MaestroPipeline$get_status()`](#method-MaestroPipeline-get_status)

- [`MaestroPipeline$get_status_chr()`](#method-MaestroPipeline-get_status_chr)

- [`MaestroPipeline$get_outputs()`](#method-MaestroPipeline-get_outputs)

- [`MaestroPipeline$get_inputs()`](#method-MaestroPipeline-get_inputs)

- [`MaestroPipeline$get_priority()`](#method-MaestroPipeline-get_priority)

- [`MaestroPipeline$get_returns()`](#method-MaestroPipeline-get_returns)

- [`MaestroPipeline$get_artifacts()`](#method-MaestroPipeline-get_artifacts)

- [`MaestroPipeline$get_n_artifacts()`](#method-MaestroPipeline-get_n_artifacts)

- [`MaestroPipeline$get_n_invocations()`](#method-MaestroPipeline-get_n_invocations)

- [`MaestroPipeline$get_all_returns()`](#method-MaestroPipeline-get_all_returns)

- [`MaestroPipeline$get_errors()`](#method-MaestroPipeline-get_errors)

- [`MaestroPipeline$get_warnings()`](#method-MaestroPipeline-get_warnings)

- [`MaestroPipeline$get_messages()`](#method-MaestroPipeline-get_messages)

- [`MaestroPipeline$get_flags()`](#method-MaestroPipeline-get_flags)

- [`MaestroPipeline$get_labels()`](#method-MaestroPipeline-get_labels)

- [`MaestroPipeline$get_is_collect()`](#method-MaestroPipeline-get_is_collect)

- [`MaestroPipeline$get_map()`](#method-MaestroPipeline-get_map)

- [`MaestroPipeline$get_is_map()`](#method-MaestroPipeline-get_is_map)

- [`MaestroPipeline$get_n_expected_iterations()`](#method-MaestroPipeline-get_n_expected_iterations)

- [`MaestroPipeline$set_n_expected_iterations()`](#method-MaestroPipeline-set_n_expected_iterations)

- [`MaestroPipeline$update_inputs()`](#method-MaestroPipeline-update_inputs)

- [`MaestroPipeline$update_outputs()`](#method-MaestroPipeline-update_outputs)

- [`MaestroPipeline$reset_run_time_attributes()`](#method-MaestroPipeline-reset_run_time_attributes)

- [`MaestroPipeline$get_run_sequence()`](#method-MaestroPipeline-get_run_sequence)

- [`MaestroPipeline$clone()`](#method-MaestroPipeline-clone)

------------------------------------------------------------------------

### `MaestroPipeline$new()`

Create a new Pipeline object

#### Usage

    MaestroPipeline$new(
      script_path,
      pipe_name,
      frequency = NA_character_,
      start_time_raw = NA_character_,
      tz = NA_character_,
      hours = NULL,
      days = NULL,
      months = NULL,
      skip = FALSE,
      log_level = "INFO",
      inputs = NULL,
      outputs = NULL,
      priority = Inf,
      flags = c(),
      run_if = NULL,
      is_collect = FALSE,
      map = NULL,
      labels = list()
    )

#### Arguments

- `script_path`:

  path to the script

- `pipe_name`:

  name of the pipeline

- `frequency`:

  frequency of the pipeline (e.g., 1 day)

- `start_time_raw`:

  start time as a raw string from the @maestroStartTime tag

- `tz`:

  time zone of the pipeline

- `hours`:

  specific hours of the day

- `days`:

  specific days of week or month

- `months`:

  specific months of year

- `skip`:

  whether to skip the pipeline regardless of scheduling

- `log_level`:

  log level of the pipeline

- `inputs`:

  names of pipelines that this pipeline is dependent on for input

- `outputs`:

  names of pipelines for which this pipeline is a dependency

- `priority`:

  priority of the pipeline

- `flags`:

  arbitrary pipelines flags

- `run_if`:

  string representing an R expression that can be evaluated and returns
  TRUE or FALSE; or NULL

- `is_collect`:

  logical; TRUE when @maestroInputs uses collect() fan-in marker

- `map`:

  named list of key=expr_string pairs from @maestroMap, or NULL

- `labels`:

  list of key-value pairs for pipeline labeling

#### Returns

MaestroPipeline object

------------------------------------------------------------------------

### `MaestroPipeline$print()`

Prints the pipeline

#### Usage

    MaestroPipeline$print()

------------------------------------------------------------------------

### `MaestroPipeline$run()`

Runs the pipeline

#### Usage

    MaestroPipeline$run(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e+06,
      .input = NULL,
      depth = 0,
      log_to_console = FALSE,
      run_id = NA_character_,
      input_run_id = NA_character_,
      lineage = c(),
      iter = NULL,
      pre_error = NULL,
      ...
    )

#### Arguments

- `resources`:

  named list of arguments and values to pass to the pipeline

- `log_file`:

  path to the log file for logging

- `quiet`:

  whether to silence console output

- `log_file_max_bytes`:

  maximum bytes of the log file before trimming

- `.input`:

  input values from upstream pipelines

- `depth`:

  number of inputting pipelines above the current

- `log_to_console`:

  whether or not to output statements in the console (FALSE is to
  suppress and append to log)

- `run_id`:

  unique id for the run

- `input_run_id`:

  unique id of the run that inputted into the current run (NA if there
  is no input)

- `lineage`:

  character vector of upstream pipeline names ordered from first to
  latest (or empty if no upstream pipes)

- `iter`:

  iteration number for dynamic fanout

- `pre_error`:

  trigger error from outside execution

- `...`:

  additional arguments (unused)

#### Returns

invisible

------------------------------------------------------------------------

### `MaestroPipeline$get_pipe_name()`

Get the pipeline name

#### Usage

    MaestroPipeline$get_pipe_name()

#### Returns

pipeline_name

------------------------------------------------------------------------

### `MaestroPipeline$get_frequency_nunits()`

Get the frequency n and unit as a list

#### Usage

    MaestroPipeline$get_frequency_nunits()

#### Returns

list with n and unit

------------------------------------------------------------------------

### `MaestroPipeline$get_schedule()`

Get the schedule as a data.frame

#### Usage

    MaestroPipeline$get_schedule()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroPipeline$check_timeliness()`

Check whether a pipeline is scheduled to run based on orchestrator
frequency and current time

#### Usage

    MaestroPipeline$check_timeliness(
      orch_unit,
      orch_n,
      check_datetime = lubridate::now(),
      ...
    )

#### Arguments

- `orch_unit`:

  unit of the orchestrator (e.g., day)

- `orch_n`:

  number of units of the frequency

- `check_datetime`:

  datetime against which to check the timeliness of the pipeline (should
  almost always be now)

- `...`:

  unused

#### Returns

MaestroPipeline

------------------------------------------------------------------------

### `MaestroPipeline$get_status()`

Get status of the pipeline as a data.frame

#### Usage

    MaestroPipeline$get_status()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroPipeline$get_status_chr()`

Get status of the pipeline as a string

#### Usage

    MaestroPipeline$get_status_chr()

#### Returns

character

------------------------------------------------------------------------

### `MaestroPipeline$get_outputs()`

Names of pipelines that receive input from this pipeline

#### Usage

    MaestroPipeline$get_outputs()

#### Returns

character

------------------------------------------------------------------------

### `MaestroPipeline$get_inputs()`

Names of pipelines that input into this pipeline

#### Usage

    MaestroPipeline$get_inputs()

#### Returns

character

------------------------------------------------------------------------

### `MaestroPipeline$get_priority()`

Get priority of the pipeline

#### Usage

    MaestroPipeline$get_priority()

#### Returns

numeric

------------------------------------------------------------------------

### `MaestroPipeline$get_returns()`

Get immediate return values from the pipeline for downstream pipelines

#### Usage

    MaestroPipeline$get_returns()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_artifacts()`

Get artifacts (return values) from the pipeline

#### Usage

    MaestroPipeline$get_artifacts()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_n_artifacts()`

Get the number of completed artifact runs (iterations) for this pipeline

#### Usage

    MaestroPipeline$get_n_artifacts()

#### Returns

integer

------------------------------------------------------------------------

### `MaestroPipeline$get_n_invocations()`

Get the number of times this pipeline was invoked (successes + errors).
For @maestroMap pipelines this equals the number of iterations that have
finished, regardless of outcome.

#### Usage

    MaestroPipeline$get_n_invocations()

#### Returns

integer

------------------------------------------------------------------------

### `MaestroPipeline$get_all_returns()`

Get all artifact values as a plain unnamed list, regardless of how many
iterations have run. Used by collect() to gather each-pipe outputs.

#### Usage

    MaestroPipeline$get_all_returns()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_errors()`

Get list of errors from the pipeline

#### Usage

    MaestroPipeline$get_errors()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_warnings()`

Get list of warnings from the pipeline

#### Usage

    MaestroPipeline$get_warnings()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_messages()`

Get list of messages from the pipeline

#### Usage

    MaestroPipeline$get_messages()

#### Returns

list

------------------------------------------------------------------------

### `MaestroPipeline$get_flags()`

Get the flags of a pipeline as a vector

#### Usage

    MaestroPipeline$get_flags()

#### Returns

character

------------------------------------------------------------------------

### `MaestroPipeline$get_labels()`

Get the labels of a pipeline as a data.frame

#### Usage

    MaestroPipeline$get_labels()

#### Returns

data.frame

------------------------------------------------------------------------

### `MaestroPipeline$get_is_collect()`

Get whether the pipeline uses `collect` for fan in

#### Usage

    MaestroPipeline$get_is_collect()

#### Returns

logical

------------------------------------------------------------------------

### `MaestroPipeline$get_map()`

Get the .input value to iterate over

#### Usage

    MaestroPipeline$get_map()

#### Returns

character

------------------------------------------------------------------------

### `MaestroPipeline$get_is_map()`

Get whether the pipeline uses an iterator for dynamic fan out

#### Usage

    MaestroPipeline$get_is_map()

#### Returns

logical

------------------------------------------------------------------------

### `MaestroPipeline$get_n_expected_iterations()`

Get the number of iterations expected for this @maestroMap pipeline. Set
by run_pipe() just before the scatter loop so that
resolve_collect_input() can compare against get_n_invocations() without
depending on the upstream return value's length (which is wrong when a
field selector is used).

#### Usage

    MaestroPipeline$get_n_expected_iterations()

#### Returns

integer or NULL

------------------------------------------------------------------------

### `MaestroPipeline$set_n_expected_iterations()`

Record the number of iterations that will be dispatched for this
@maestroMap pipeline.

#### Usage

    MaestroPipeline$set_n_expected_iterations(n)

#### Arguments

- `n`:

  integer

#### Returns

invisible

------------------------------------------------------------------------

### `MaestroPipeline$update_inputs()`

Update the inputs of a pipeline

#### Usage

    MaestroPipeline$update_inputs(inputs)

#### Arguments

- `inputs`:

  character vector of inputting pipeline names

#### Returns

vector

------------------------------------------------------------------------

### `MaestroPipeline$update_outputs()`

Update the outputs of a pipeline

#### Usage

    MaestroPipeline$update_outputs(outputs)

#### Arguments

- `outputs`:

  character vector of outputting pipeline names

#### Returns

vector

------------------------------------------------------------------------

### `MaestroPipeline$reset_run_time_attributes()`

Resets run time attributes

#### Usage

    MaestroPipeline$reset_run_time_attributes()

#### Returns

invisible

------------------------------------------------------------------------

### `MaestroPipeline$get_run_sequence()`

Get the run sequence of a pipeline

#### Usage

    MaestroPipeline$get_run_sequence(
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

vector

------------------------------------------------------------------------

### `MaestroPipeline$clone()`

The objects of this class are cloneable with this method.

#### Usage

    MaestroPipeline$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
