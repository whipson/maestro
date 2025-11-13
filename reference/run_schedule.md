# Run a schedule

Given a schedule in a `maestro` project, runs the pipelines that are
scheduled to execute based on the current time.

## Usage

``` r
run_schedule(
  schedule,
  orch_frequency = "1 day",
  check_datetime = lubridate::now(tzone = "UTC"),
  resources = list(),
  run_all = FALSE,
  n_show_next = 5,
  cores = 1,
  log_file_max_bytes = 1e+06,
  quiet = FALSE,
  log_to_console = FALSE,
  log_to_file = FALSE
)
```

## Arguments

- schedule:

  object of type MaestroSchedule created using
  [`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)

- orch_frequency:

  of the orchestrator, a single string formatted like "1 day", "2
  weeks", "hourly", etc.

- check_datetime:

  datetime against which to check the running of pipelines (default is
  current system time in UTC)

- resources:

  named list of shared resources made available to pipelines as needed

- run_all:

  run all pipelines regardless of the schedule (default is `FALSE`) -
  useful for testing. Does not apply to pipes with a `maestroSkip` tag.
  Conditional pipelines using `maestroRunIf` still behave according to
  their condition.

- n_show_next:

  show the next n scheduled pipes

- cores:

  number of cpu cores to run if running in parallel. If \> 1, `furrr` is
  used and a multisession plan must be executed in the orchestrator (see
  details)

- log_file_max_bytes:

  numeric specifying the maximum number of bytes allowed in the log file
  before purging the log (within a margin of error)

- quiet:

  silence metrics to the console (default = `FALSE`). Note this does not
  affect messages generated from pipelines when `log_to_console = TRUE`.

- log_to_console:

  whether or not to include pipeline messages, warnings, errors to the
  console (default = `FALSE`) (see Logging & Console Output section)

- log_to_file:

  either a boolean to indicate whether to create and append to a
  `maestro.log` or a character path to a specific log file. If `FALSE`
  or `NULL` it will not log to a file.

## Value

MaestroSchedule object

## Details

### Pipeline schedule logic

The function `run_schedule()` examines each pipeline in the schedule
table and determines whether it is scheduled to run at the current time
using some simple time arithmetic. We assume
`run_schedule(schedule, check_datetime = Sys.time())`, but this need not
be the case.

### Output

`run_schedule()` returns the same MaestroSchedule object with modified
attributes. Use
[`get_status()`](https://whipson.github.io/maestro/reference/get_status.md)
to examine the status of each pipeline and use
[`get_artifacts()`](https://whipson.github.io/maestro/reference/get_artifacts.md)
to get any return values from the pipelines as a list.

### Pipelines with arguments (resources)

If a pipeline takes an argument that doesn't include a default value,
these can be supplied in the orchestrator via
`run_schedule(resources = list(arg1 = val))`. The name of the argument
used by the pipeline must match the name of the argument in the list.
Currently, each named resource must refer to a single object. In other
words, you can't have two pipes using the same argument but requiring
different values.

### Running in parallel

Pipelines can be run in parallel using the `cores` argument. First, you
must run `future::plan(future::multisession)` in the orchestrator. Then,
supply the desired number of cores to the `cores` argument. Note that
console output appears different in multicore mode.

### Logging & Console Output

By default, `maestro` suppresses pipeline messages, warnings, and errors
from appearing in the console, but messages coming from
[`print()`](https://rdrr.io/r/base/print.html) and other console logging
packages like `cli` and `logger` are not suppressed and will be
interwoven into the output generated from `run_schedule()`. Messages
from [`cat()`](https://rdrr.io/r/base/cat.html) and related functions
are always suppressed due to the nature of how those functions operate
with standard output.

Users are advised to make use of R's
[`message()`](https://rdrr.io/r/base/message.html),
[`warning()`](https://rdrr.io/r/base/warning.html), and
[`stop()`](https://rdrr.io/r/base/stop.html) functions in their
pipelines for managing conditions. Use `log_to_console = TRUE` to print
these to the console.

Maestro can generate a log file that is appended to each time the
orchestrator is run. Use `log_to_file = TRUE` or
`log_to_file = '[path-to-file]'` and maestro will create/append to a
file in the project directory. This log file will be appended to until
it exceeds the byte size defined in `log_file_max_bytes` argument after
which the log file is deleted.

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
  schedule <- build_schedule(pipeline_dir = pipeline_dir)

  # Runs the schedule every 1 day
  run_schedule(
    schedule,
    orch_frequency = "1 day",
    quiet = TRUE
  )

  # Runs the schedule every 15 minutes
  run_schedule(
    schedule,
    orch_frequency = "15 minutes",
    quiet = TRUE
  )
}
```
