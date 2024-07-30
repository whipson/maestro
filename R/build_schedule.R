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
#' @return data.frame
#' @export
#' @examples
#'
#' # Creating a temporary directory for demo purposes! In practice, just
#' # create a 'pipelines' directory at the project level.
#' pipeline_dir <- tempdir()
#' create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#' build_schedule(pipeline_dir = pipeline_dir)
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
  attempted_sch_parses <- purrr::map(
    pipelines, purrr::safely(build_schedule_entry)
  ) |>
    stats::setNames(basename(pipelines))

  # Check uniqueness of the function names
  pipe_names <- purrr::map(attempted_sch_parses, ~{
    .x$result$pipe_name
  }) |>
    purrr::list_c()

  # Check for uniqueness of pipe names
  # if (length(unique(pipe_names)) < length(pipe_names)) {
  #   non_unique_names <- pipe_names[duplicated(pipe_names)]
  #   cli::cli_abort(
  #     c("Function names must all be unique",
  #       "i" = "{.fn {non_unique_names}} used more than once.")
  #   )
  # }

  # Get the results
  sch_results <- purrr::map(
    attempted_sch_parses,
    ~.x$result
  ) |>
    purrr::discard(is.null)

  # Get the errors
  sch_errors <- purrr::map(
    attempted_sch_parses,
    ~.x$error
  ) |>
    purrr::discard(is.null)

  # Assign the errors to the pkgenv
  maestro_pkgenv$last_build_errors <- sch_errors

  if (!quiet) {
    maestro_parse_cli(sch_results, sch_errors)
  }

  # Return the results
  sch <- sch_results |>
    purrr::list_rbind() |>
    # Supply default values for missing
    dplyr::mutate(
      frequency = dplyr::if_else(is.na(frequency), "1 day", frequency),
      start_time = dplyr::if_else(is.na(start_time), "1970-01-01 00:00:00", start_time),
      tz = dplyr::if_else(is.na(tz), "UTC", tz),
      skip = dplyr::if_else(is.na(skip), FALSE, TRUE),
      log_level = dplyr::if_else(is.na(log_level), "INFO", log_level),
      frequency_n = dplyr::if_else(is.na(frequency_n), 1L, frequency_n),
      frequency_unit = dplyr::if_else(is.na(frequency_unit), "day", frequency_unit),
      start_time = purrr::map2_vec(start_time, tz, ~lubridate::as_datetime(.x, tz = .y))
    ) |>
    dplyr::select(-tz)

  return(sch)
}
