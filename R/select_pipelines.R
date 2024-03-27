#' Select pipelines
#'
#' @param .data data.frame with pipeline name, interval, frequency, and start datetime
#' @param orch_interval a numeric value representing how often the orchestration runs
#' @param orch_unit unit of how often the orchestration runs (i.e. min, hour, day, month, etc.)
#' @param check_datetime datetime used to check against the pipeline start datetime, default is the system time
#'
#' @return data.frame
#'
select_pipelines <- function(.data, orch_interval, orch_unit, check_datetime = Sys.time()) {

  # Assertion tests
  # Check input parameters data type
  assertthat::assert_that(is.numeric(orch_interval), msg = "orch_interval must be a numeric value")
  assertthat::assert_that(is.character(orch_unit), msg = "orch_unit must be chacter value")
  assertthat::assert_that(lubridate::is.POSIXct(check_datetime), msg = "check_datetime must be a datatime with a yyyy-mm-dd hh:mm:ss format")

  # Check input parameters values
  assertthat::assert_that(orch_unit %in% c("mins", "hour", "day", "week", "month", "quarter", "year"), msg = "orch_unit must be one of the following units: mins, hour, day, week, month, quarter, year")


  # Code within the function

  is_scheduled <- purrr::pmap_lgl(
    list(.data$interval, .data$frequency, .data$start_datetime),
    ~{
      identify_pipelines(orch_interval, orch_unit, check_datetime, ..1, ..2, ..3)
    }
  )

  # Assertion tests
  # Check objects have a length great than zero
  assertthat::assert_that(length(is_scheduled) > 0)

  .data[is_scheduled,]
}
