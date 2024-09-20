#' Get the schedule from a MaestroSchedule object
#'
#' A schedule is represented as a table where each row is a pipeline and
#' the columns contain scheduling parameters such as the frequency and start time.
#'
#' The schedule table is used internally in a MaestroSchedule object but can be
#' accessed using this function or accessing the R6 method of the MaestroSchedule
#' object.
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
#'   get_schedule(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_schedule()
#' }
get_schedule <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_schedule()
}
