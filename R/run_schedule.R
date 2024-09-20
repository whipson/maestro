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
#' @param schedule object of type MaestroSchedule created using `build_schedule()`
#' @inheritParams get_pipeline_run_sequence
#' @param orch_frequency of the orchestrator, a single string formatted like "1 day", "2 weeks", "hourly", etc.
#' @param resources named list of shared resources made available to pipelines as needed
#' @param run_all run all pipelines regardless of the schedule (default is `FALSE`) - useful for testing.
#' Does not apply to pipes with a `maestroSkip` tag.
#' @param n_show_next show the next n scheduled pipes
#' @param cores number of cpu cores to run if running in parallel. If > 1, `furrr` is used and
#' a multisession plan must be executed in the orchestrator (see details)
#' @param logging whether or not to write the logs to a file (default = `FALSE`)
#' @param log_file path to the log file (ignored if `logging == FALSE`)
#' @param log_file_max_bytes numeric specifying the maximum number of bytes allowed in the log file before purging the log (within a margin of error)
#' @param quiet silence metrics to the console (default = `FALSE`)
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
    logging = FALSE,
    log_file = NULL,
    log_file_max_bytes = 1e6,
    quiet = FALSE
) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # Get the orchestrator nunits
  orch_nunits <- tryCatch({
    parse_rounding_unit(orch_frequency)
  }, error = \(e) {
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.",
        "i" = "Must be of the format like '1 day', '2 weeks', 'hourly', etc."
      ),
      call = NULL
    )
  })

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

  # Ensure that log file exists if it's requested
  if (logging) {
    if (!rlang::is_scalar_character(log_file)) cli::cli_abort(
      "When {.code logging == TRUE}, {.code log_file} must be a single character."
    )
    if (!file.exists(log_file)) file.create(log_file)
  } else {
    log_file <- tempfile()
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
    log_file = log_file,
    log_file_max_bytes = log_file_max_bytes,
    quiet = quiet
  )

  return(schedule)
}
