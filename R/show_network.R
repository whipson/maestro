#' Visualize the schedule as a DAG
#'
#' Create an interactive network visualization to show the dependency structure
#' of pipelines in the schedule. This is only useful if there are pipelines in
#' the schedule that take inputs/outputs from other pipelines.
#'
#' Note that running this function on a schedule with all independent pipelines
#' will produce a network visual with no connections.
#'
#' This function requires the installation of `DiagrammeR` which is not automatically
#' installed with `maestro`.
#'
#' @inheritParams run_schedule
#'
#' @return DiagrammeR visualization
#' @export
#'
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
#'   show_network(schedule)
#' }
show_network <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$show_network()
}
