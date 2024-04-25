#' Check which pipelines are scheduled to run and when next pipelines will run
#'
#' @param .data data.frame with pipeline name, interval, frequency, and start datetime
#' @param orch_interval a numeric value representing how often the orchestration runs
#' @param orch_unit unit of how often the orchestration runs (i.e. min, hour, day, month, etc.)
#' @param check_datetime datetime used to check against the pipeline start datetime
#'
#' @return list
#'
check_pipelines <- function(.data, orch_interval, orch_unit, check_datetime) {

  # Assertion tests
  # Check input parameters data type
  assertthat::assert_that(is.numeric(orch_interval), msg = "`orch_interval` must be a numeric value")
  assertthat::assert_that(orch_interval >= 1, msg = "`orch_interval` must be a positive integer")
  assertthat::assert_that((orch_interval %% 1) == 0, msg = "`orch_interval` must be an integer. Decimal values not allowed.")
  assertthat::assert_that(lubridate::is.POSIXct(check_datetime), msg = "`check_datetime` must be a POSIXct datetime object")

  # Check input parameters values
  assertthat::assert_that(
    orch_unit %in% c("minute", "hour", "day", "week", "month", "quarter", "year"),
    msg = "`orch_unit` must be one of the following units: minute, hour, day, week, month, quarter, year"
  )

  schedule_checks <- purrr::pmap(
    list(.data$interval, .data$frequency, .data$start_time),
    ~{
      check_pipeline_next_schedule(orch_interval, orch_unit, check_datetime, ..1, ..2, ..3)
    }
  )

  schedule_checks
}
