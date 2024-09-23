#' Build a schedule table
#'
#' Builds a schedule data.frame for scheduling pipelines in `run_schedule()`.
#'
#' This function parses the maestro tags of functions located in `pipeline_dir` which is
#' conventionally called 'pipelines'. An orchestrator requires a schedule table
#' to determine which pipelines are to run and when. Each row in a schedule table
#' is a pipeline name and its scheduling parameters such as its frequency.
#'
#' The schedule table is mostly intended to be used by `run_schedule()` immediately.
#' In other words, it is not recommended to make changes to it.
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#' @param quiet silence metrics to the console (default = `FALSE`)
#'
#' @return MaestroSchedule
#' @export
#' @examples
#'
#' # Creating a temporary directory for demo purposes! In practice, just
#' # create a 'pipelines' directory at the project level.
#'
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   build_schedule(pipeline_dir = pipeline_dir)
#' }
build_schedule <- function(pipeline_dir = "./pipelines", quiet = FALSE) {

  if (!dir.exists(pipeline_dir)) {
    cli::cli_abort("No directory called {.emph {pipeline_dir}}")
  }

  # Parse all the .R files in the `pipeline_dir` directory
  pipelines <- list.files(
    pipeline_dir,
    pattern = "*.R$",
    full.names = TRUE
  )

  # Error if the directory has no .R scripts
  if(length(pipelines) == 0) {
    cli::cli_inform(
      "No R scripts in {pipeline_dir}."
    )
    return(invisible())
  }

  # Try to generate a schedule entry for each script
  # We use safely to ensure it continues in an error condition and capture the errors
  pipeline_attempts <- purrr::map(
    pipelines, purrr::safely(build_schedule_entry)
  ) |>
    stats::setNames(basename(pipelines))

  # Get the results
  pipeline_results <- purrr::map(
    pipeline_attempts,
    ~.x$result
  ) |>
    purrr::discard(is.null)

  # Get the errors
  pipeline_errors <- purrr::map(
    pipeline_attempts,
    ~.x$error
  ) |>
    purrr::discard(is.null)

  # Assign the errors to the pkgenv
  maestro_pkgenv$last_build_errors <- pipeline_errors

  # Check uniqueness of the function names
  pipe_names <- purrr::map(pipeline_results, ~{
    .x$get_pipe_names()
  }) |>
    purrr::list_c()

  # Check for uniqueness of pipe names
  if (length(unique(pipe_names)) < length(pipe_names)) {
    non_unique_names <- pipe_names[duplicated(pipe_names)]
    cli::cli_abort(
      c("Function names must all be unique",
        "i" = "{.code {non_unique_names}} used more than once.")
    )
  }

  # Create the schedule
  schedule <- MaestroSchedule$new(Pipelines = pipeline_results)

  if (!quiet) {
    maestro_parse_cli(pipeline_results, pipeline_errors)
  }

  schedule
}
