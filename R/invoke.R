#' Manually run a pipeline regardless of schedule
#'
#' Instantly run a single pipeline from the schedule. This is useful for testing
#' purposes or if you want to just run something one-off.
#'
#' Scheduling parameters such as the frequency, start time, and specifiers are ignored.
#' The pipeline will be run even if `maestroSkip` is present. If the pipeline is a DAG
#' pipeline, `invoke` will attempt to execute the full DAG.
#'
#' @inheritParams run_schedule
#' @param pipe_name name of a single pipe name from the schedule
#' @param ... other arguments passed to `run_schedule()`
#'
#' @return invisible
#' @export
#'
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   invoke(schedule, "my_new_pipeline")
#' }
invoke <- function(schedule, pipe_name, resources = list(), ...) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  pipe_names <- schedule$PipelineList$get_pipe_names()

  if (!rlang::is_scalar_character(pipe_name)) {
    cli::cli_abort(
      c("`pipe_name` must be a single character string referencing the name of a pipeline in the schedule.",
        "i" = "Available pipe_names are {.pkg {sort(pipe_names)}}"),
      call = rlang::caller_env()
    )
  }

  # Make sure pipe name is in the schedule
  if (!pipe_name %in% pipe_names) {
    cli::cli_abort(
      c("{.code {pipe_name}} is not the name of a pipeline in the schedule.",
        "i" = "Available pipe_names are {.pkg {sort(pipe_names)}}"),
      call = rlang::caller_env()
    )
  }

  # Ensure that elements in resources are named
  if (length(resources) > 0) {
    resources_length <- length(resources)
    n_named <- sum(names(resources) != "")
    if (resources_length > n_named) {
      cli::cli_abort(
        "All elements in `resources` must be named."
      )
    }

    n_uniq_names <- length(unique(names(resources)))
    if (resources_length > n_uniq_names) {
      cli::cli_abort(
        "All elements in `resources` must have unique names."
      )
    }
  }

  tryCatch({
    schedule$PipelineList$run(..., resources = resources, pipes_to_run = pipe_name)
  }, error = function(e) {

    if (e$message == "unused argument (`NA` = NULL)") {
      cli::cli_abort(
        c(
          "Failed to invoke pipeline {.code {pipe_name}}",
          "i" = "Did you forget to pass pipeline arguments as `resources = list(name = val)`?"
        ),
        call = NULL
      )
    } else {
      cli::cli_abort(
        "Failed to invoke pipeline {.code {pipe_name}}",
        call = NULL
      )
    }
  })

  return(invisible())
}
