#' Update a metric for the currently running pipeline
#'
#' Records or overwrites a named metric for the pipeline
#' currently being executed by `run_schedule()`. Call this from within a pipeline
#' function's body - `maestro` automatically attributes the metric to the pipeline and
#' run that is currently executing, so there's no need to pass the pipe name yourself.
#'
#' Calling `update_metric()` again with the same `name` during the same pipeline run
#' overwrites the previous value (last write wins), unless `increment = TRUE`, in which
#' case `value` is added to the existing value instead (accumulating across calls). This
#' works even if the metric hasn't been set yet in the current run - the first call just
#' sets it, same as a regular update. Metrics from prior runs of the same pipeline are
#' preserved and returned separately by `get_metrics()`.
#'
#' @param name character scalar; the name of the metric to set (e.g. `"rows_in"`).
#' @param value numeric scalar to record for `name`.
#' @param increment logical; if `TRUE`, `value` is added to the metric's current value
#'   (within the current pipeline run) instead of overwriting it. A negative `value`
#'   will therefore decrement it. Default `FALSE`.
#'
#' Calling `update_metric()` outside of a pipeline run (e.g. while developing or testing a
#' pipeline function interactively) is not an error - it emits an informational message and
#' has no effect.
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
#'     # Accumulate a count across a loop
#'     for (chunk in split_into_chunks(data)) {
#'       process_chunk(chunk)
#'       update_metric("chunks_processed", 1, increment = TRUE)
#'     }
#'
#'     out
#'   }
#' }
update_metric <- function(name, value, increment = FALSE) {

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

  if (!rlang::is_scalar_logical(increment) || is.na(increment)) {
    cli::cli_abort(
      "`increment` must be a single, non-missing logical value.",
      call = rlang::caller_env()
    )
  }

  pipe <- maestro_pkgenv$run_context_pipe
  run_id <- maestro_pkgenv$run_context_run_id

  if (is.null(pipe)) {
    cli::cli_inform(
      "{.fn update_metric} was called outside of a pipeline run and will have no effect. Metrics are only recorded when the pipeline is executed by {.fn run_schedule}."
    )
    return(invisible(NULL))
  }

  pipe$set_metric(name, value, run_id, increment = increment)

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
