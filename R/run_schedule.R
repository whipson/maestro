#' Run a schedule
#'
#' Given a schedule in a `maestro` project, runs the pipelines that are scheduled to execute
#' based on the current time.
#'
#' @md
#' @details
#'
#' ## Pipeline schedule logic
#'
#' The function `run_schedule()` examines each pipeline in the schedule table and determines
#' whether it is scheduled to run at the current time using some simple time arithmetic. We assume
#' `run_schedule(schedule, check_datetime = Sys.time())`, but this need not be the case.
#'
#' ## Output
#'
#' `run_schedule()` returns the same MaestroSchedule object with modified attributes. Use `get_status()`
#' to examine the status of each pipeline and use `get_artifacts()` to get any return values from the
#' pipelines as a list.
#'
#' ## Pipelines with arguments (resources)
#'
#' If a pipeline takes an argument that doesn't include a default value, these can be supplied
#' in the orchestrator via `run_schedule(resources = list(arg1 = val))`. The name of the argument
#' used by the pipeline must match the name of the argument in the list. Currently, each named
#' resource must refer to a single object. In other words, you can't have two pipes using
#' the same argument but requiring different values.
#'
#' ## Running in parallel
#'
#' Pipelines can be run in parallel using the `cores` argument. First, you must run `future::plan(future::multisession)`
#' in the orchestrator. Then, supply the desired number of cores to the `cores` argument. Note that
#' console output appears different in multicore mode.
#'
#' ## Logging & Console Output
#'
#' By default, `maestro` suppresses pipeline messages, warnings, and errors from appearing in the console, but
#' messages coming from `print()` and other console logging packages like `cli` and `logger` are not suppressed
#' and will be interwoven into the output generated from `run_schedule()`. Messages from `cat()` and related functions are always suppressed
#' due to the nature of how those functions operate with standard output.
#'
#' Users are advised to make use of R's `message()`, `warning()`, and `stop()` functions in their pipelines
#' for managing conditions. Use `log_to_console = TRUE` to print these to the console.
#'
#' Maestro can generate a log file that is appended to each time the orchestrator is run. Use `log_to_file = TRUE` or `log_to_file = '[path-to-file]'` and
#' maestro will create/append to a file in the project directory.
#' This log file will be appended to until it exceeds the byte size defined in `log_file_max_bytes` argument after which
#' the log file is deleted.
#'
#' @param schedule object of type MaestroSchedule created using `build_schedule()`
#' @inheritParams get_pipeline_run_sequence
#' @param orch_frequency of the orchestrator, a single string formatted like "1 day", "2 weeks", "hourly", etc.
#' @param resources named list of shared resources made available to pipelines as needed
#' @param run_all run all pipelines regardless of the schedule (default is `FALSE`) - useful for testing.
#' Does not apply to pipes with a `maestroSkip` tag.
#' @param n_show_next show the next n scheduled pipes
#' @param cores number of cpu cores to run if running in parallel. If > 1, `furrr` is used and
#' a multisession plan must be executed in the orchestrator (see details)
#' @param logging whether or not to write the logs to a file (deprecated in 0.5.0 - use `log_to_file` and/or `log_to_console` arguments instead)
#' @param log_file path to the log file (ignored if `log_to_file == FALSE`) (deprecated in 0.5.0 - use `log_to_file`)
#' @param log_file_max_bytes numeric specifying the maximum number of bytes allowed in the log file before purging the log (within a margin of error)
#' @param quiet silence metrics to the console (default = `FALSE`). Note this does not affect messages generated from pipelines when `log_to_console = TRUE`.
#' @param log_to_console whether or not to include pipeline messages, warnings, errors to the console (default = `FALSE`) (see Logging & Console Output section)
#' @param log_to_file either a boolean to indicate whether to create and append to a `maestro.log` or a character path to a specific log file. If `FALSE` or `NULL` it will not log to a file.
#'
#' @return MaestroSchedule object
#' @importFrom R.utils countLines
#' @export
#' @examples
#'
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   # Runs the schedule every 1 day
#'   run_schedule(
#'     schedule,
#'     orch_frequency = "1 day",
#'     quiet = TRUE
#'   )
#'
#'   # Runs the schedule every 15 minutes
#'   run_schedule(
#'     schedule,
#'     orch_frequency = "15 minutes",
#'     quiet = TRUE
#'   )
#' }
run_schedule <- function(
    schedule,
    orch_frequency = "1 day",
    check_datetime = lubridate::now(tzone = "UTC"),
    resources = list(),
    run_all = FALSE,
    n_show_next = 5,
    cores = 1,
    logging = lifecycle::deprecated(),
    log_file = lifecycle::deprecated(),
    log_file_max_bytes = 1e6,
    quiet = FALSE,
    log_to_console = FALSE,
    log_to_file = FALSE
) {

  warned_about_logging_dep <- FALSE
  if (lifecycle::is_present(logging)) {
    lifecycle::deprecate_warn(
      "0.5.0",
      "maestro::run_schedule(logging)",
      "maestro::run_schedule(log_to_file)",
      details = "To enable logging to a file use either `log_to_file = TRUE` or, more specifically, `log_to_file = '[path-to-log-file]'`"
    )
    warned_about_logging_dep <- TRUE
    log_to_file <- TRUE
  }

  if (lifecycle::is_present(log_file)) {
    if (!warned_about_logging_dep) {
      lifecycle::deprecate_warn(
        "0.5.0",
        "maestro::run_schedule(log_file)",
        "maestro::run_schedule(log_to_file)",
        details = "To enable logging to a file use either `log_to_file = TRUE` or, more specifically, `log_to_file = '[path-to-log-file]'`"
      )
    }
    log_to_file <- log_file
  }

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if (!(lubridate::is.Date(check_datetime) | lubridate::is.POSIXct(check_datetime))) {
    cli::cli_abort("`check_datetime` must be a {.cls Date} or {.cls POSIXct} type.")
  }

  # Get the orchestrator nunits
  orch_nunits <- tryCatch({
    parse_rounding_unit(orch_frequency)
  }, error = \(e) {
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.",
        "i" = "Must be of the format like '1 day', '1 week', 'hourly', etc."
      ),
      call = NULL
    )
  })

  # Enforce minimum orch frequency of 1 year
  if (orch_nunits$unit == "year" && orch_nunits$n > 1) {
    cli::cli_abort(
      "Invalid `orch_frequency` {orch_frequency}. Minimum frequency is 1 year.",
      call = NULL
    )
  }

  # Additional parse using timechange to verify it isn't something like 500 days,
  # which isn't understood by timechange
  tryCatch({
    timechange::time_round(Sys.time(), paste(orch_nunits$n, orch_nunits$unit))
  }, error = \(e) {
    timechange_error_fmt <- gsub('\\..*', '', e$message)
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.
        {timechange_error_fmt}."
      ),
      call = NULL
    )
  })

  # Warn if running the orchestrator less frequent than the highest frequency pipeline
  sch <- get_schedule(schedule)

  if (nrow(sch) > 0 && !run_all) {
    sch_nunits <- sch |>
      dplyr::select(pipe_name, frequency_n, frequency_unit) |>
      dplyr::filter(!is.na(frequency_n))
    sch_units_lt_orch_unit <- units_lt_units(sch_nunits$frequency_unit, standardize_units(orch_nunits$unit))
    if (any(sch_units_lt_orch_unit)) {
      which_sch_nunits_lt_orch_unit <- sch_nunits[sch_units_lt_orch_unit,]
      offending_pipe_names <- which_sch_nunits_lt_orch_unit$pipe_name
      offending_pipe_units <- which_sch_nunits_lt_orch_unit$frequency_unit
      cli::cli_warn(
        c(
          "Pipeline{?s} {.pkg {offending_pipe_names}} {?has/have} {? a frequency/frequencies} higher (i.e., more often)
        than the frequency of the orchestrator. This means the pipeline{?s} will not run as frequently as specified.",
          "i" = "Consider increasing the frequency of the orchestrator or decreasing the pipeline frequency."
        )
      )
    }
  }

  # Check if we're logging to a file
  if (!rlang::is_scalar_logical(log_to_file) && !rlang::is_scalar_character(log_to_file)) {
    cli::cli_abort(
      "When not NULL, {.code log_to_file} must be a single boolean or a single character string."
    )
  }

  if (is.logical(log_to_file) && log_to_file) {
    log_to_file <- "maestro.log"
  }

  if (is.character(log_to_file)) {
    if (!file.exists(log_to_file)) file.create(log_to_file)
  } else {
    log_to_file <- tempfile()
  }

  # Ensure that elements in resources are named
  if (length(resources) > 0) {
    resources_length <- length(resources)
    n_named <- sum(names(resources) != "")
    if (resources_length > n_named) {
      cli::cli_abort(
        "All elements in `resources` must be named."
      )
    }

    n_uniq_names <- length(unique(names(resources)))
    if (resources_length > n_uniq_names) {
      cli::cli_abort(
        "All elements in `resources` must have unique names."
      )
    }
  }

  schedule$run(
    orch_n = orch_nunits$n,
    orch_unit = orch_nunits$unit,
    check_datetime = check_datetime,
    resources = resources,
    run_all = run_all,
    n_show_next = n_show_next,
    cores = cores,
    log_file = log_to_file,
    log_file_max_bytes = log_file_max_bytes,
    quiet = quiet,
    log_to_console = log_to_console
  )

  return(schedule)
}
