#' Get the run sequence of a schedule
#'
#' Retrieves the scheduled run times for a given schedule, with optional filtering
#' by number of runs and datetime range.
#'
#' @inheritParams run_schedule
#' @param n Optional positive integer. If specified, returns only the first `n` runs for each pipeline.
#' @param min_datetime Optional minimum datetime filter. Can be a [Date] or [POSIXct] object.
#'   If specified, only returns runs scheduled at or after this datetime.
#' @param max_datetime Optional maximum datetime filter. Can be a [Date] or [POSIXct] object.
#'   If specified, only returns runs scheduled at or before this datetime.
#' @param include_only_primary only primary pipelines are included 
#'   (this are pipelines that are scheduled and not downstream nodes in a DAG)
#'
#' @return A vector of datetime values representing the scheduled run times.
#'
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   get_run_sequence(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_run_sequence()
#' }
#' @export
get_run_sequence <- function(schedule, n = NULL, min_datetime = NULL, max_datetime = NULL, include_only_primary = FALSE) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if (!is.null(n)) {
    if (!rlang::is_scalar_integerish(n) || n < 1) {
      cli::cli_abort(
        "`n` must be a positive integer.",
        call = rlang::caller_env()
      )
    }
  }

  if (!is.null(min_datetime)) {
    if (!inherits(min_datetime, c("Date", "POSIXct", "POSIXlt"))) {
      cli::cli_abort(
        "`min_datetime` must be a Date or POSIXct object.",
        call = rlang::caller_env()
      )
    }
  }

  if (!is.null(max_datetime)) {
    if (!inherits(max_datetime, c("Date", "POSIXct", "POSIXlt"))) {
      cli::cli_abort(
        "`max_datetime` must be a Date or POSIXct object.",
        call = rlang::caller_env()
      )
    }
  }

  if (!rlang::is_scalar_logical(include_only_primary)) {
    cli::cli_abort(
      "`include_only_primary` must be a boolean.",
      call = rlang::caller_env()
    )
  }

  if (!is.null(min_datetime) && !is.null(max_datetime)) {
    if (min_datetime > max_datetime) {
      cli::cli_abort(
        "`min_datetime` cannot be greater than `max_datetime`.",
        call = rlang::caller_env()
      )
    }
  }

  schedule$get_run_sequence(
    n = n,
    min_datetime = min_datetime, 
    max_datetime = max_datetime,
    include_only_primary = include_only_primary
  )
}