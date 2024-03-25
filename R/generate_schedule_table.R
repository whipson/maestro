#' Generate schedule table
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#'
#' @return data.frame
#' @export
#'
#' @examples
generate_schedule_table <- function(pipeline_dir = "./pipelines") {

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
    pipelines, purrr::safely(schedule_entry_from_script)
  ) |>
    setNames(basename(pipelines))

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
      frequency = dplyr::coalesce(frequency, "daily"),
      interval = dplyr::coalesce(interval, 1L),
      start_time = dplyr::coalesce(start_time, as.character(Sys.time())),
      tz = dplyr::coalesce(tz, "UTC")
    ) |>
    dplyr::rowwise() |>
    # Format timestamp with timezone
    dplyr::mutate(
      start_time = lubridate::as_datetime(start_time, tz = tz)
    ) |>
    dplyr::ungroup()

  return(sch)
}
