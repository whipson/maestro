#' Build schedule table
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#'
#' @return data.frame
#' @export
build_schedule <- function(pipeline_dir = "./pipelines") {

  # Parse all the .R files in the `pipeline_dir` directory
  pipelines <- list.files(
    pipeline_dir,
    pattern = "*.R$",
    full.names = TRUE
  )

  # Error if the directory has no .R scripts
  if(length(pipelines) == 0) {
    cli::cli_abort(
      "No directory called {.emph {pipeline_dir}} containing any R scripts exists.
      `pipeline_dir` must reference a directory with at least one R script."
    )
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
  baton_pkgenv$latest_parsing_errors <- sch_errors

  baton_parse_cli(sch_results, sch_errors)

  # Return the results
  sch <- sch_results |>
    purrr::list_rbind() |>
    # Supply default values for missing
    dplyr::mutate(
      frequency = dplyr::coalesce(frequency, "day"),
      interval = dplyr::coalesce(interval, 1L),
      start_time = dplyr::coalesce(start_time, "1970-01-01 00:00:00"),
      tz = dplyr::coalesce(tz, "UTC"),
      skip = dplyr::coalesce(skip, FALSE)
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
