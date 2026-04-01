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
#' ## Caching
#'
#' For large projects, parsing pipeline scripts on every orchestrator run can be slow.
#' Use `cache_schedule()` to persist a built schedule to disk and `from_cache` to reload
#' it on subsequent runs. The run sequences are automatically refreshed when loading from
#' cache—tag parsing is skipped entirely.
#'
#' ```r
#' # First run: build from scripts and cache the result
#' schedule <- build_schedule("pipelines/")
#' cache_schedule(schedule)
#'
#' # Subsequent runs: load from cache (fast)
#' schedule <- build_schedule(from_cache = ".maestro/schedule.rds")
#' ```
#'
#' **Important:** the cache is a snapshot of the schedule at the time it was built.
#' You must rebuild from scripts and call `cache_schedule()` again whenever any of
#' the following change:
#'
#' - A pipeline is **added**, **removed**, or **renamed**
#' - Any `@maestro*` tag is **modified** (frequency, start time, inputs, flags, etc.)
#' - A pipeline script is **moved** to a different location
#'
#' Only the run sequences (future scheduled datetimes) are refreshed from cache—all
#' pipeline configuration comes from the cached snapshot. If the cache is stale,
#' those changes will be silently ignored.
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#' @param from_cache path to a cached schedule `.rds` file created by
#'   `cache_schedule()`. When supplied, `pipeline_dir` is ignored and the
#'   schedule is loaded from the cache with run sequences refreshed automatically.
#'   The cache must be regenerated whenever pipeline scripts or tags change.
#'   Set to `NULL` (default) to build from scripts as usual.
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
build_schedule <- function(pipeline_dir = "./pipelines", from_cache = NULL, quiet = FALSE) {

  # --- Cache path: skip parsing entirely ---
  if (!is.null(from_cache)) {

    if (!rlang::is_scalar_character(from_cache)) {
      cli::cli_abort(
        "`from_cache` must be a single character string (a path to an `.rds` file).",
        call = rlang::caller_env()
      )
    }

    if (!file.exists(from_cache)) {
      cli::cli_abort(
        "Cache file {.file {from_cache}} does not exist.",
        call = rlang::caller_env()
      )
    }

    schedule <- tryCatch(
      readRDS(from_cache),
      error = function(e) {
        cli::cli_abort(
          "Could not read cache file {.file {from_cache}}: {e$message}",
          call = rlang::caller_env()
        )
      }
    )

    if (!"MaestroSchedule" %in% class(schedule)) {
      cli::cli_abort(
        c(
          "The object at {.file {from_cache}} is not a {.cls MaestroSchedule}.",
          "i" = "Use {.fn cache_schedule} to create a valid cache file."
        ),
        call = rlang::caller_env()
      )
    }

    refresh_schedule(schedule, quiet = quiet)

    return(schedule)
  }

  # --- Normal path: parse pipeline scripts ---

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

  # Validate the schedule
  schedule$PipelineList$validate_network()

  if (!quiet) {
    maestro_parse_cli(pipeline_results, pipeline_errors)
  }

  schedule
}
