#' Get the flags of pipelines in a MaestroSchedule object
#'
#' Creates a long data.frame where each row is a flag for each pipeline.
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
#'   get_flags(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_flags()
#' }
get_flags <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_flags()
}
