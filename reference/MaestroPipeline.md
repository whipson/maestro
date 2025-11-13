# Class for an individual maestro pipeline A pipeline is defined as a single R script with a schedule or input

Class for an individual maestro pipeline A pipeline is defined as a
single R script with a schedule or input

Class for an individual maestro pipeline A pipeline is defined as a
single R script with a schedule or input

## Methods

### Public methods

- [`MaestroPipeline$new()`](#method-MaestroPipeline-new)

- [`MaestroPipeline$print()`](#method-MaestroPipeline-print)

- [`MaestroPipeline$run()`](#method-MaestroPipeline-run)

- [`MaestroPipeline$get_pipe_name()`](#method-MaestroPipeline-get_pipe_name)

- [`MaestroPipeline$get_schedule()`](#method-MaestroPipeline-get_schedule)

- [`MaestroPipeline$check_timeliness()`](#method-MaestroPipeline-check_timeliness)

- [`MaestroPipeline$get_status()`](#method-MaestroPipeline-get_status)

- [`MaestroPipeline$get_status_chr()`](#method-MaestroPipeline-get_status_chr)

- [`MaestroPipeline$get_outputs()`](#method-MaestroPipeline-get_outputs)

- [`MaestroPipeline$get_inputs()`](#method-MaestroPipeline-get_inputs)

- [`MaestroPipeline$get_priority()`](#method-MaestroPipeline-get_priority)

- [`MaestroPipeline$get_artifacts()`](#method-MaestroPipeline-get_artifacts)

- [`MaestroPipeline$get_errors()`](#method-MaestroPipeline-get_errors)

- [`MaestroPipeline$get_warnings()`](#method-MaestroPipeline-get_warnings)

- [`MaestroPipeline$get_messages()`](#method-MaestroPipeline-get_messages)

- [`MaestroPipeline$get_flags()`](#method-MaestroPipeline-get_flags)

- [`MaestroPipeline$update_inputs()`](#method-MaestroPipeline-update_inputs)

- [`MaestroPipeline$update_outputs()`](#method-MaestroPipeline-update_outputs)

- [`MaestroPipeline$get_run_sequence()`](#method-MaestroPipeline-get_run_sequence)

- [`MaestroPipeline$clone()`](#method-MaestroPipeline-clone)

------------------------------------------------------------------------

### Method `new()`

Create a new Pipeline object

#### Usage

    MaestroPipeline$new(
      script_path,
      pipe_name,
      frequency = NA_character_,
      start_time = lubridate::NA_POSIXct_,
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
      run_if = NULL
    )

#### Arguments

- `script_path`:

  path to the script

- `pipe_name`:

  name of the pipeline

- `frequency`:

  frequency of the pipeline (e.g., 1 day)

- `start_time`:

  start time of the pipeline

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

#### Returns

MaestroPipeline object

------------------------------------------------------------------------

### Method [`print()`](https://rdrr.io/r/base/print.html)

Prints the pipeline

#### Usage

    MaestroPipeline$print()

#### Returns

print

------------------------------------------------------------------------

### Method `run()`

Runs the pipeline

#### Usage

    MaestroPipeline$run(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e+06,
      .input = NULL,
      cli_prepend = "",
      log_to_console = FALSE,
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

- `cli_prepend`:

  text to prepend to cli output

- `log_to_console`:

  whether or not to output statements in the console (FALSE is to
  suppress and append to log)

- `...`:

  additional arguments (unused)

#### Returns

invisible

------------------------------------------------------------------------

### Method `get_pipe_name()`

Get the pipeline name

#### Usage

    MaestroPipeline$get_pipe_name()

#### Returns

pipeline_name

------------------------------------------------------------------------

### Method [`get_schedule()`](https://whipson.github.io/maestro/reference/get_schedule.md)

Get the schedule as a data.frame

#### Usage

    MaestroPipeline$get_schedule()

#### Returns

data.frame

------------------------------------------------------------------------

### Method `check_timeliness()`

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

### Method [`get_status()`](https://whipson.github.io/maestro/reference/get_status.md)

Get status of the pipeline as a data.frame

#### Usage

    MaestroPipeline$get_status()

#### Returns

data.frame

------------------------------------------------------------------------

### Method `get_status_chr()`

Get status of the pipeline as a string

#### Usage

    MaestroPipeline$get_status_chr()

#### Returns

character

------------------------------------------------------------------------

### Method `get_outputs()`

Names of pipelines that receive input from this pipeline

#### Usage

    MaestroPipeline$get_outputs()

#### Returns

character

------------------------------------------------------------------------

### Method `get_inputs()`

Names of pipelines that input into this pipeline

#### Usage

    MaestroPipeline$get_inputs()

#### Returns

character

------------------------------------------------------------------------

### Method `get_priority()`

Get priority of the pipeline

#### Usage

    MaestroPipeline$get_priority()

#### Returns

numeric

------------------------------------------------------------------------

### Method [`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md)

Get artifacts (return values) from the pipeline

#### Usage

    MaestroPipeline$get_artifacts()

#### Returns

list

------------------------------------------------------------------------

### Method `get_errors()`

Get list of errors from the pipeline

#### Usage

    MaestroPipeline$get_errors()

#### Returns

list

------------------------------------------------------------------------

### Method `get_warnings()`

Get list of warnings from the pipeline

#### Usage

    MaestroPipeline$get_warnings()

#### Returns

list

------------------------------------------------------------------------

### Method `get_messages()`

Get list of messages from the pipeline

#### Usage

    MaestroPipeline$get_messages()

#### Returns

list

------------------------------------------------------------------------

### Method [`get_flags()`](https://whipson.github.io/maestro/reference/get_flags.md)

Get the flags of a pipeline as a vector

#### Usage

    MaestroPipeline$get_flags()

#### Returns

character

------------------------------------------------------------------------

### Method `update_inputs()`

Update the inputs of a pipeline

#### Usage

    MaestroPipeline$update_inputs(inputs)

#### Arguments

- `inputs`:

  character vector of inputting pipeline names

#### Returns

vector

------------------------------------------------------------------------

### Method `update_outputs()`

Update the outputs of a pipeline

#### Usage

    MaestroPipeline$update_outputs(outputs)

#### Arguments

- `outputs`:

  character vector of outputting pipeline names

#### Returns

vector

------------------------------------------------------------------------

### Method `get_run_sequence()`

Get the run sequence of a pipeline

#### Usage

    MaestroPipeline$get_run_sequence()

#### Arguments

- `outputs`:

  character vector of times

#### Returns

vector

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    MaestroPipeline$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
