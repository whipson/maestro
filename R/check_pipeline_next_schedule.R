#' Check pipeline next schedule
#'
#' Checks if a pipeline is scheduled to run and when it is next supposed to run
#'
#' @param orch_interval a numeric value representing how often the orchestration runs
#' @param orch_frequency unit of how often the orchestration runs (i.e. min, hour, day, month, etc.)
#' @param check_datetime datetime to be used to check if the pipeline should run
#' @param pipeline_interval a numeric value representing how often the pipeline runs
#' @param pipeline_freq unit of how often the pipeline runs (i.e. min, hour, day, month, etc.)
#' @param pipeline_datetime datetime of the first time the pipeline is to run
#'
#' @return list
#'
check_pipeline_next_schedule <- function(
    orch_interval,
    orch_frequency,
    check_datetime,
    pipeline_interval,
    pipeline_freq,
    pipeline_datetime
  ) {

  # Convert minute to mins for compatibility with seq
  pipeline_freq <- ifelse(pipeline_freq == "minute", "mins", pipeline_freq)

  # Code within the function
  # Validation to see if pipeline should be run
  check_datetime_round <- lubridate::round_date(check_datetime, unit = paste(orch_interval, orch_frequency))
  pipeline_datetime_round <- lubridate::round_date(pipeline_datetime, unit = paste(orch_interval, orch_frequency))

  if (pipeline_datetime_round > check_datetime_round) {
    pipeline_sequence <- pipeline_datetime_round
  } else {
    pipeline_sequence <- seq(pipeline_datetime_round, check_datetime_round, by = paste(pipeline_interval, pipeline_freq))
  }

  cur_run <- utils::tail(pipeline_sequence, n = 1)
  is_scheduled_now <- check_datetime_round == cur_run
  next_run <- utils::tail(seq(from = cur_run, length.out = 2, by = paste(pipeline_interval, pipeline_freq)), n = 1)

  list(
    next_run = next_run,
    is_scheduled_now = is_scheduled_now
  )
}
