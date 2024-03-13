#' Generate schedule table
#'
#' @param pipeline_dir path to directory containing the pipeline scripts
#'
#' @return data.frame
#' @export
#'
#' @examples
generate_schedule_table <- function(pipeline_dir = "./pipelines") {

  # Parse all the files in the `pipeline_dir` directory
  pipelines <- list.files(pipeline_dir, full.names = TRUE)

  purrr::imap(pipelines, schedule_entry_from_script) |>
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
}
