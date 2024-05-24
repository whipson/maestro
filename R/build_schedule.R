#' Build a schedule table
#'
#' Builds a schedule data.frame for scheduling pipelines in `run_schedule()`. This
#' function parses the decorators of functions located in `pipeline_dir` which is
#' conventionally called pipelines.
#'
#' @md
#' @details
#'
#' An orchestrator requires a schedule table to determine which pipelines are to
#' run and when. Each row in a schedule table is a pipeline name and its
#' scheduling parameters such as its frequency.
#'
#' ## Basic workflow
#'
#' In a basic `maestro` workflow, you would run `run_schedule()` in the orchestrator
#' every time to ensure that the orchestrator is running off the latest schedule.
#'
#' ## Advanced workflow
#'
#' If shaving off a few milliseconds of compute time is important, you can create
#' the schedule once, cache it somewhere in your project directory, and read it
#' in before executing `run_schedule(schedule)`.
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#'
#' @return data.frame
#' @export
#' @examples
#'
#' # Creating a temporary directory for demo purposes! In practice, just
#' # create a 'pipelines' directory at the project level.
#' dir.create("pipelines")
#' build_schedule()
#'
build_schedule <- function(pipeline_dir = "./pipelines") {

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
    setNames(basename(pipelines))

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
  maestro_pkgenv$last_parsing_errors <- sch_errors

  maestro_parse_cli(sch_results, sch_errors)

  # Return the results
  sch <- sch_results |>
    purrr::list_rbind() |>
    # Supply default values for missing
    dplyr::mutate(
      frequency = dplyr::coalesce(frequency, "day"),
      interval = dplyr::coalesce(interval, 1L),
      start_time = dplyr::coalesce(start_time, "1970-01-01 00:00:00"),
      tz = dplyr::coalesce(tz, "UTC"),
      skip = dplyr::coalesce(skip, FALSE),
      log_level = dplyr::coalesce(log_level, "INFO")
    ) |>
    dplyr::rowwise() |>
    # Format timestamp with timezone
    dplyr::mutate(
      start_time = lubridate::as_datetime(start_time, tz = tz)
    ) |>
    dplyr::ungroup() |>
    dplyr::select(-tz)

  return(sch)
}
