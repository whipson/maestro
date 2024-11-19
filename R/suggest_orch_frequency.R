#' Suggest orchestrator frequency based on a schedule
#'
#' Suggests a frequency to run the orchestrator based on the frequencies of the
#' pipelines in a schedule.
#'
#' This function attempts to find the smallest interval of time between all pipelines.
#' If the smallest interval is less than 15 minutes, it just uses the smallest interval.
#'
#' Note this function is intended to be used interactively when deciding how often to
#' schedule the orchestrator. Programmatic use is not recommended.
#'
#' @param schedule MaestroSchedule object created by `build_schedule()`
#' @inheritParams get_pipeline_run_sequence
#'
#' @return frequency string
#' @export
#'
#' @examples
#'
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'   suggest_orch_frequency(schedule)
#' }
suggest_orch_frequency <- function(schedule, check_datetime = lubridate::now(tzone = "UTC")) {

  # Check that schedule is a MaestroSchedule
  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  schedule <- schedule$get_schedule() |>
    dplyr::filter(!skip, !is.na(frequency_n))

  if (nrow(schedule) == 0) {

    cli::cli_abort(
      c(
        "No pipelines in schedule after removing skipped pipelines.",
        "i" = "Remove `maestroSkip` tags to get a suggested frequency."
      )
    )
  }

  sch_secs <- purrr::map_int(
    paste(schedule$frequency_n, schedule$frequency_unit),
    purrr::possibly(convert_to_seconds, otherwise = NA, quiet = TRUE)
  )

  # If the minimum schedule seconds is lte 15 minutes, return the corresponding frequency
  if (min(sch_secs, na.rm = TRUE) <= (60 * 15)) {
    return(schedule$frequency[[which.min(sch_secs)]])
  }

  if (nrow(schedule) == 1) {
    return(schedule$frequency)
  }

  max_idx <- which.max(sch_secs)
  max_freq <- paste(schedule$frequency_n[[max_idx]], schedule$frequency_unit[[max_idx]])

  pipeline_sequences <- purrr::pmap(
    list(schedule$frequency_n, schedule$frequency_unit, schedule$start_time),
    ~{
      pipeline_sequence <- get_pipeline_run_sequence(
        ..1, ..2, ..3,
        check_datetime = check_datetime + lubridate::seconds(convert_to_seconds(max_freq))
      )

      pipeline_sequence[pipeline_sequence >= check_datetime]
    }
  ) |>
    purrr::list_c() |>
    unique() |>
    sort()

  if (length(pipeline_sequences) == 1) return(max_freq)

  pipeline_diffs <- diff(pipeline_sequences)

  min_diff_secs <- min(pipeline_diffs)

  min_diff_atts <- attributes(min_diff_secs)

  paste(round(as.numeric(min_diff_secs)), min_diff_atts$units)
}
