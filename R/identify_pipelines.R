#' Identify pipelines
#'
#' @param orch_interval a numeric value representing how often the orchestration runs
#' @param orch_unit unit of how often the orchestration runs (i.e. min, hour, day, month, etc.)
#' @param check_datetime datetime to be used to check if the pipeline should run, default is system time
#' @param pipeline_interval a numeric value representing how often the pipeline runs
#' @param pipeline_freq unit of how often the pipeline runs (i.e. min, hour, day, month, etc.)
#' @param pipeline_datetime datatime of the first time the pipeline is to run
#'
#' @return
#'
identify_pipelines <- function(orch_interval, orch_unit, check_datetime = Sys.time(), pipeline_interval, pipeline_freq, pipeline_datetime) {

  # Assertion tests
  # Check input parameters data type
  assertthat::assert_that(is.numeric(orch_interval), msg = "orch_interval must be a numeric value")
  assertthat::assert_that(is.character(orch_unit), msg = "orch_unit must be chacter value")
  assertthat::assert_that(lubridate::is.POSIXct(check_datetime), msg = "check_datetime must be a datatime with a yyyy-mm-dd hh:mm:ss format")
  assertthat::assert_that(is.numeric(pipeline_interval), msg = "pipeline_interval must be a numeric value")
  assertthat::assert_that(is.character(pipeline_freq), msg = "pipeline_freq must be a character value")
  assertthat::assert_that(lubridate::is.POSIXct(pipeline_datetime), msg = "pipeline_datetime must be a datatime with a yyyy-mm-dd hh:mm:ss format")

  # Check input parameters values
  assertthat::assert_that(orch_unit %in% c("minute", "hour", "day", "week", "month", "quarter", "year"), msg = "orch_unit must be one of the following units: mins, hour, day, week, month, quarter, year")
  assertthat::assert_that(pipeline_freq %in% c("minute", "hour", "day", "week", "month", "quarter", "year"), msg = "pipeline_freq must be one of the following units: mins, hour, day, week, month, quarter, year")

  # Convert minute to mins for compatibility with seq
  pipeline_freq <- ifelse(pipeline_freq == "minute", "mins", pipeline_freq)

  # Code within the function
  # Validation to see if pipeline should be run
  check_datetime_round <- lubridate::round_date(check_datetime, unit = paste(orch_interval, orch_unit, sep = " "))
  pipeline_datetime_round <- lubridate::round_date(pipeline_datetime, unit = paste(orch_interval, orch_unit, sep = " "))
  pipeline_sequence <- seq(pipeline_datetime_round, check_datetime_round, by = paste(pipeline_interval, pipeline_freq, sep = " "))

  pipeline_check <- check_datetime_round == tail(pipeline_sequence, n = 1)
  return(pipeline_check)
}
