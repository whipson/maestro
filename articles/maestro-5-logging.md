# Logging

Logging is critical for monitoring pipelines in a deployed environment.
Logging is a way of tracking error messages, warnings, and other user
generated informational messages. Maestro provides several options for
logging these conditions from pipelines - logging to a file and/or
logging to the console. Maestro leverages
[logger](https://daroczig.github.io/logger/) for managing and formatting
logs.

## Conditions in R: Message, Warning, Error

R has three types of conditions (increasing in severity): message,
warning, and error. Maestro makes use of this system for reporting the
statuses of pipelines and for managing logs. For this reason, we
recommend using [`message()`](https://rdrr.io/r/base/message.html) for
adding informational logs to pipelines in contrast to
[`print()`](https://rdrr.io/r/base/print.html) and
[`cat()`](https://rdrr.io/r/base/cat.html).

There are also several logging packages for R including `logger` and
`logr`. As we’ll see later, these can be integrated with maestro as well
with some special modifications.

## Log to File

Maestro allows for a log file to be continuously appended to with
pipeline logs. Conventionally, we give it a name of `maestro.log`, but
this can be any text file. Here we create a sample set of 3 pipelines,
one with a message, one with a warning, and another with an error.

``` r
#' pipelines/logs.R
#' @maestroFrequency hourly
hello <- function() {
  message('hello')
}

#' @maestroFrequency hourly
uhh <- function() {
  warning('this could be a problem')
}

#' @maestroFrequency hourly
oh_no <- function() {
  stop('this is bad')
}
```

Now we run the orchestrator. For demo purposes, we’ll set
`run_all = TRUE` to allow all pipelines to run regardless of scheduling.
We set `log_to_file = TRUE` argument to tell it to log to a file. This
creates (and later appends to) a generic ‘maestro.log’ file in the
project directory. We can see the typical output of a maestro schedule
as the pipeline runs.

``` r
# orchestrator.R
library(maestro)

schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule, 
  run_all = TRUE,
  log_to_file = TRUE
)
```

    ── [2025-12-09 16:59:45]
    Running pipelines ▶
    ✔ hello [19ms]
    ✔ uhh [120ms]
    ✖ oh_no [14ms]

    ── [2025-12-09 16:59:45]
    Pipeline execution completed ■ | 0.203 sec elapsed
    ✔ 2 successes | ! 1 warning | ✖ 1 error | ◼ 3 total
    ✖ Use `last_run_errors()` to show pipeline errors.
    ! Use `last_run_warnings()` to show pipeline warnings.
    ────────────────────────────────────────────────────────────────────────────────

Now let’s take a look at the log file. We can see the logs formatted
with the name of the pipeline from where the message came, the type of
log (INFO, WARN, or ERROR), the timestamp, and the message itself.

``` r
readLines("maestro.log")
```

    [1] "[hello] [INFO] [2025-12-09 16:59:45.740235]: hello"
    [2] ""
    [3] "[uhh] [WARN] [2025-12-09 16:59:45.788203]: this could be a problem"
    [4] "[oh_no] [ERROR] [2025-12-09 16:59:45.908682]: this is bad"

## Log to Console

We can also have the logs printed directly to the console using the
`log_to_console` argument.

``` r
# orchestrator.R
schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule, 
  run_all = TRUE,
  log_to_console = TRUE
)
```

    ── [2025-12-09 16:59:46]
    Running pipelines ▶
    [hello] [INFO] [2025-12-09 16:59:46.151254]: hello

    ✔ hello [10ms]
    [uhh] [WARN] [2025-12-09 16:59:46.170122]: this could be a problem
    ✔ uhh [13ms]
    [oh_no] [ERROR] [2025-12-09 16:59:46.191933]: this is bad
    ✖ oh_no [15ms]

    ── [2025-12-09 16:59:46]
    Pipeline execution completed ■ | 0.064 sec elapsed
    ✔ 2 successes | ! 1 warning | ✖ 1 error | ◼ 3 total
    ✖ Use `last_run_errors()` to show pipeline errors.
    ! Use `last_run_warnings()` to show pipeline warnings.
    ────────────────────────────────────────────────────────────────────────────────

Now the logs have been interwoven with the output from maestro. Both
logging options operate independently, so it is possible to log to a
file and to the console.

## Log Levels

Maestro uses the concept of log levels (also known as thresholds) to
allow users to suppress logs that do not meet a severity threshold. If,
for example, you were only concerned with error messages and wanted to
ignore warnings and info messages, you would use the `maestroLogLevel`
tag for the relevant pipelines.

``` r
#' pipelines/logs.R
#' @maestroFrequency hourly
#' @maestroLogLevel ERROR
hello <- function() {
  message('hello')
}

#' @maestroFrequency hourly
#' @maestroLogLevel ERROR
uhh <- function() {
  warning('this could be a problem')
}

#' @maestroFrequency hourly
#' @maestroLogLevel ERROR
oh_no <- function() {
  stop('this is bad')
}
```

Now, only the error messages are displayed and logged.

``` r
# orchestrator.R
schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule, 
  run_all = TRUE,
  log_to_console = TRUE
)
```

    ── [2025-12-09 16:59:46]
    Running pipelines ▶
    ✔ hello [9ms]
    ✔ uhh [9ms]
    [oh_no] [ERROR] [2025-12-09 16:59:46.437606]: this is bad
    ✖ oh_no [11ms]

    ── [2025-12-09 16:59:46]
    Pipeline execution completed ■ | 0.058 sec elapsed
    ✔ 2 successes | ! 1 warning | ✖ 1 error | ◼ 3 total
    ✖ Use `last_run_errors()` to show pipeline errors.
    ! Use `last_run_warnings()` to show pipeline warnings.
    ────────────────────────────────────────────────────────────────────────────────

By default, pipelines use a log level of INFO, which means that all
messages, warnings, and errors are logged.

## Other Loggers

If you wish to use other logging libraries, we recommend using
[logger](https://daroczig.github.io/logger/). You can put these
statements anywhere in your pipelines and they’ll propagate into the
logs that maestro uses. Best approach is to use the `namespace` argument
and reference the name of the pipeline.

``` r
#' pipelines/logs.R
#' @maestroFrequency hourly
hello <- function() {
  logger::log_info("hi", namespace = "hello")
}

#' @maestroFrequency hourly
uhh <- function() {
  logger::log_warn("this could be a problem", namespace = "uhh")
}

#' @maestroFrequency hourly
oh_no <- function() {
  logger::log_error("this is bad", namespace = "oh_no")
}
```

``` r
# orchestrator.R
schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule, 
  run_all = TRUE,
  log_to_console = TRUE
)
```

    ── [2025-12-09 16:59:46]
    Running pipelines ▶
    [hello] [INFO] [2025-12-09 16:59:46.631182]: hi
    ✔ hello [10ms]
    [uhh] [WARN] [2025-12-09 16:59:46.653017]: this could be a problem
    ✔ uhh [15ms]
    [oh_no] [ERROR] [2025-12-09 16:59:46.674285]: this is bad
    ✔ oh_no [15ms]

    ── [2025-12-09 16:59:46]
    Pipeline execution completed ■ | 0.067 sec elapsed
    ✔ 3 successes | ! 0 warnings | ✖ 0 errors | ◼ 3 total
    ────────────────────────────────────────────────────────────────────────────────

Note that logger just creates messages and does not actually trigger
conditions. This impacts how the statuses of pipelines appear. It is
important to use match the namespace with the name of your pipeline
(i.e., the function name) for the logs to appear in a log file.
