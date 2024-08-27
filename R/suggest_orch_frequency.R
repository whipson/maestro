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
#' @param schedule schedule data.frame created by `build_schedule()`
#' @inheritParams check_pipelines
#'
#' @return frequency string
#' @export
#'
#' @examples
#'
#' suggest_orch_frequency(example_schedule)
suggest_orch_frequency <- function(schedule, check_datetime = lubridate::now(tzone = "UTC")) {

  # Check that schedule is a data.frame
  if (!"data.frame" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be a data.frame and not an object of class {class(schedule)}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # Check that schedule has at least one row
  if (nrow(schedule) == 0) {
    cli::cli_abort(
      c("Empty schedule. Schedule must have at least one row.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if (!"frequency" %in% names(schedule)) {
    cli::cli_abort(
      c("Schedule is missing required column 'frequency'.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."
      ),
      call = rlang::caller_env()
    )
  }

  if (typeof(schedule$frequency) != "character") {
    cli::cli_abort(
      c("Schedule columns {.code frequency} must have type 'character'.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if (!"start_time" %in% names(schedule)) {
    cli::cli_abort(
      c("Schedule is missing required column 'start_time'.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."
      ),
      call = rlang::caller_env()
    )
  }

  if (!"POSIXct" %in% class(schedule$start_time)) {
    cli::cli_abort(
      c("Schedule columns {.code start_time} must have type 'POSIXct'.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if ("skip" %in% names(schedule)) {

    if (typeof(schedule$skip) != "logical") {
      cli::cli_abort(
        c("Schedule columns {.code skip} must have type 'logical'.",
          "i" = "Use {.fn build_schedule} to create a valid schedule."),
        call = rlang::caller_env()
      )
    }

    schedule <- schedule |>
      dplyr::filter(!skip)

    if (nrow(schedule) == 0) {

      cli::cli_abort(
        c(
          "No pipelines in schedule after removing skipped pipelines.",
          "i" = "Remove `maestroSkip` tags to get a suggested frequency."
        )
      )
    }
  }

  sch_secs <- purrr::map_int(
    paste(schedule$frequency_n, schedule$frequency_unit),
    purrr::possibly(convert_to_seconds, otherwise = NA, quiet = TRUE)
  )

  if (any(is.na(sch_secs))) {
    cli::cli_abort(
      c("There are invalid time units.",
        "i" = "Use {.fn build_schedule} to create a valid schedule.")
    )
  }

  # If the minimum schedule seconds is lte 15 minutes, return the corresponding frequency
  if (min(sch_secs, na.rm = TRUE) <= (60 * 15)) {
    return(schedule$frequency[[which.min(sch_secs)]])
  }

  if (nrow(schedule) == 1) {
    return(schedule$frequency)
  }

  max_freq <- schedule$frequency[[which.max(sch_secs)]]

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
