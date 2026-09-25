#' Update a metric for the currently running pipeline
#'
#' Records or overwrites a named metric for the pipeline
#' currently being executed by `run_schedule()`. Call this from within a pipeline
#' function's body - `maestro` automatically attributes the metric to the pipeline and
#' run that is currently executing, so there's no need to pass the pipe name yourself.
#'
#' Calling `update_metric()` again with the same `name` during the same pipeline run
#' overwrites the previous value (last write wins). Metrics from prior runs of the
#' same pipeline are preserved and returned separately by `get_metrics()`.
#'
#' @param name character scalar; the name of the metric to set (e.g. `"rows_in"`).
#' @param value numeric scalar to record for `name`.
#'
#' @return invisible `NULL`
#' @export
#' @examples
#' if (interactive()) {
#'   # Inside a pipeline function:
#'   my_pipeline <- function() {
#'     data <- get_data()
#'     update_metric("rows_in", nrow(data))
#'
#'     out <- process(data)
#'     update_metric("rows_out", nrow(out))
#'
#'     out
#'   }
#' }
update_metric <- function(name, value) {

  if (!rlang::is_scalar_character(name) || is.na(name) || trimws(name) == "") {
    cli::cli_abort(
      "`name` must be a single, non-missing, non-empty string.",
      call = rlang::caller_env()
    )
  }

  if (!rlang::is_scalar_double(value) && !rlang::is_scalar_integer(value)) {
    cli::cli_abort(
      "`value` must be a numeric scalar.",
      call = rlang::caller_env()
    )
  }

  if (is.na(value)) {
    cli::cli_abort(
      "`value` must not be `NA`.",
      call = rlang::caller_env()
    )
  }

  pipe <- maestro_pkgenv$run_context_pipe
  run_id <- maestro_pkgenv$run_context_run_id

  if (is.null(pipe)) {
    cli::cli_abort(
      "{.fn update_metric} can only be called from within a pipeline function that is being executed by {.fn run_schedule}.",
      call = rlang::caller_env()
    )
  }

  pipe$set_metric(name, value, run_id)

  invisible(NULL)
}

#' Get metrics recorded by pipelines in a MaestroSchedule object
#'
#' Creates a long data.frame of metrics recorded via `update_metric()` for all
#' pipelines in the schedule, across all runs.
#'
#' @inheritParams run_schedule
#'
#' @return data.frame with columns `pipe_name`, `run_id`, `metric`, `value` (numeric)
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
#'   get_metrics(schedule)
#'
#'   # Alternatively, use the underlying R6 method
#'   schedule$get_metrics()
#' }
get_metrics <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule$get_metrics()
}
