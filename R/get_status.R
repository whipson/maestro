#' Get the statuses of the pipelines in a MaestroSchedule object
#'
#' A status data.frame contains the names and locations of the pipelines as
#' well as information around whether they were invoked, the status (error, warning, etc.),
#' and the run time.
#'
#' @inheritParams run_schedule
#'
#' @return data.frame
#' @export
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   schedule <- run_schedule(
#'     schedule,
#'     orch_frequency = "1 day",
#'     quiet = TRUE
#'   )
#'
#'   get_status(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_status()
#' }
get_status <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_status()
}
