#' Suggest an orchestrator frequency based on a schedule
#'
#' Suggests a frequency to run the orchestrator based on the frequencies of the
#' pipelines in a schedule.
#'
#' This function uses a simple heuristic to suggest an orchestrator frequency. It
#' halves the frequency of the most frequent pipeline in the schedule, unless that
#' frequency is less than or equal 15 minutes, in which case it is just the highest
#' frequency.
#'
#' @param schedule schedule data.frame created by `build_schedule()`. If `NULL` it looks to the
#' environment called from `run_schedule()`
#' @param env an environment
#'
#' @return frequency string
#' @export
#'
#' @examples
#' pipeline_dir <- tempdir()
#' create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#' schedule <- build_schedule(pipeline_dir = pipeline_dir)
#' suggest_orch_frequency(schedule)
#'
#' # Use with `run_schedule()`
#' run_schedule(
#'   schedule,
#'   orch_frequency = suggest_orch_frequency()
#' )
suggest_orch_frequency <- function(schedule = NULL, env = rlang::caller_env()) {

  # Check if NULL, if it is, look in the parent environment
  if (is.null(schedule)) {
    schedule <- get("schedule", envir = env)
    if (is.null(schedule)) {
      cli::cli_abort(
        c(
          "No object named `schedule` located in the environment.",
          "i" = "Use {.fn build_schedule} to create a valid schedule."
        )
      )
    }
  }

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

  sch_secs <- purrr::map_int(schedule$frequency, convert_to_seconds)
  min_freq <- schedule$frequency[which.min(sch_secs)][[1]]

  if (min(sch_secs) <= 60 * 15) {
    return(min_freq)
  }

  nunits <- parse_rounding_unit(min_freq)

  if (nunits$n == 1) {

    frequency <- dplyr::case_when(
      nunits$unit == "year" ~ "6 months",
      nunits$unit == "quarter" ~ "2 months",
      nunits$unit == "month" ~ "2 weeks",
      nunits$unit == "week" ~ "4 days",
      nunits$unit == "day" ~ "12 hours",
      nunits$unit == "hour" ~ "30 minutes"
    )
  } else {
    new_n <- ceiling(nunits$n / 2)
    frequency <- paste(new_n, nunits$unit)
  }

  return(frequency)
}
