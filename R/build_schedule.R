#' Build a schedule
#'
#' Builds a `MaestroSchedule` object for use in `run_schedule()`.
#'
#' This function parses the maestro tags of functions located in `pipeline_dir` which is
#' conventionally called 'pipelines'. An orchestrator requires a `MaestroSchedule`
#' to determine which pipelines are to run and when. Each pipeline in the schedule
#' is a parsed function and its scheduling parameters such as its frequency.
#'
#' The `MaestroSchedule` is mostly intended to be passed directly to `run_schedule()`.
#' In other words, it is not recommended to make changes to it.
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#' @param cores number of cpu cores to use when parsing pipeline scripts. If > 1,
#'   `furrr` is used and a multisession plan must be set in the orchestrator
#'   (e.g. `future::plan(future::multisession)`). See `run_schedule()` for details.
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
build_schedule <- function(pipeline_dir = "./pipelines", cores = 1L, quiet = FALSE) {

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
  if (length(pipelines) == 0) {
    cli::cli_inform(
      "No R scripts in {pipeline_dir}."
    )
    return(invisible())
  }

  if (cores < 1 || (cores %% 1) != 0) cli::cli_abort("`cores` must be a positive integer")
  is_multicore <- FALSE
  if (cores > 1) {
    tryCatch({
      rlang::check_installed("furrr")
      is_multicore <- TRUE
    }, error = \(e) {
      cli::cli_warn("{.pkg furrr} is required for running on multiple cores.")
    })
  }

  mapper_fun <- if (is_multicore) {
    function(...) {
      furrr::future_map(
        ...,
        .options = furrr::furrr_options(
          packages = c("maestro", "logger"),
          stdout = FALSE,
          seed = NULL
        )
      )
    }
  } else {
    purrr::map
  }

  pipeline_attempts <- mapper_fun(
    pipelines, purrr::safely(build_schedule_entry)
  ) |>
    stats::setNames(basename(pipelines))

  pipeline_results <- purrr::map(
    pipeline_attempts,
    ~.x$result
  ) |>
    purrr::discard(is.null)

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

  schedule <- MaestroSchedule$new(Pipelines = pipeline_results)

  schedule$PipelineList$validate_network()

  if (!quiet) {
    maestro_parse_cli(pipeline_results, pipeline_errors)
  }

  schedule
}
