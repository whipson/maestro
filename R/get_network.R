#' Get the network structure of pipelines in a MaestroSchedule object
#'
#' Returns the pipeline dependency structure as an edge list data.frame.
#' Each row represents a directed dependency between two pipelines. The
#' result will be empty if there are no DAG pipelines in the schedule.
#'
#' @inheritParams run_schedule
#'
#' @return data.frame with columns `from` and `to`
#' @export
#' @seealso [maestro::show_network()] which is deprecated in favour of this function.
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   get_network(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_network()
#' }
get_network <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_network()
}
