#' Check pipeline next schedule
#'
#' Checks if a pipeline is scheduled to run and when it is next supposed to run
#'
#' @inheritParams check_pipelines
#' @param check_datetime datetime to be used to check if the pipeline should run
#' @param pipeline_seconds unit of how often the pipeline runs (i.e. min, hour, day, month, etc.)
#' @param pipeline_datetime datetime of the first time the pipeline is to run
#'
#' @return list
check_pipeline_next_schedule <- function(
    orch_frequency,
    check_datetime,
    pipeline_seconds,
    pipeline_datetime
  ) {

  # Code within the function
  # Validation to see if pipeline should be run
  check_datetime_round <- timechange::time_round(check_datetime, unit = paste(orch_frequency, "aseconds"))
  pipeline_datetime_round <- timechange::time_round(pipeline_datetime, unit = paste(orch_frequency, "aseconds"))

  if (pipeline_datetime_round > check_datetime_round) {
    pipeline_sequence <- pipeline_datetime_round
  } else {
    pipeline_sequence <- seq(pipeline_datetime_round, check_datetime_round, by = lubridate::period(pipeline_seconds))
  }

  cur_run <- utils::tail(pipeline_sequence, n = 1)
  is_scheduled_now <- check_datetime_round == cur_run
  next_run <- utils::tail(seq(from = cur_run, length.out = 2, by = pipeline_seconds / 60 / 60), n = 1)

  list(
    next_run = next_run,
    is_scheduled_now = is_scheduled_now
  )
}
