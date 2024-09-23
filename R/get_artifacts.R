#' Get the artifacts (return values) of the pipelines in a MaestroSchedule object.
#'
#' Artifacts are return values from pipelines. They are accessible as a named list
#' where the names correspond to the names of the pipeline.
#' @inheritParams run_schedule
#'
#' @return named list
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
#'   get_artifacts(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_artifacts()
#' }
get_artifacts <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_artifacts()
}
