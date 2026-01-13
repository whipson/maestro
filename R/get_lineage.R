#' Get the lineage of pipeline executions in a schedule run
#'
#' For DAG pipelines, lineage is the network connecting each pipeline run to its downstream pipeline run. 
#' This function returns a from-to data.frame where each run_id is linked to its downstream run_id. This 
#' function is particularly useful when paired with `get_status()` for the purpose of tracking statuses
#' of distinct pipeline lineages.
#'
#' @inheritParams run_schedule
#'
#' @return data.frame
#'
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   get_lineage(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_lineage()
#' }
#' @export
get_lineage <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_lineage()
}