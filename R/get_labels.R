#' Get the labels of pipelines in a MaestroSchedule object
#'
#' Creates a data.frame of labels for all labelled pipelines in the schedule.
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
#'   get_labels(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_labels()
#' }
get_labels <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_labels()
}
