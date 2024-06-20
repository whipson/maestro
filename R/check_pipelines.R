#' Check which pipelines are scheduled to run and when next pipelines will run
#'
#' @param check_datetime datetime to be used to check if the pipeline should run
#' @param pipeline_n number of units for the pipeline frequency
#' @param pipeline_unit unit for the pipeline frequency
#' @param pipeline_datetime datetime of the first time the pipeline is to run
#' @param orch_n number of units for the orchestrator frequency
#' @param orch_unit unit for the orchestrator frequency
#'
#' @return list
check_pipelines <- function(
    orch_unit,
    orch_n,
    pipeline_unit,
    pipeline_n,
    check_datetime,
    pipeline_datetime
  ) {

  orch_frequency_seconds <- convert_to_seconds(paste(orch_n, orch_unit))
  check_datetime_round <- timechange::time_round(check_datetime, unit = paste(orch_n, orch_unit))

  schedule_checks <- purrr::pmap(
    list(pipeline_n, pipeline_unit, pipeline_datetime),
    ~{
      pipeline_frequency_seconds <- convert_to_seconds(paste(..1, ..2))

      # Code within the function
      # Validation to see if pipeline should be run
      pipeline_datetime_round <- timechange::time_round(..3, unit = paste(orch_n, orch_unit))

      pipeline_unit <- dplyr::case_match(
        ..2,
        c("minutes", "minute") ~ "min",
        c("seconds", "second") ~ "sec",
        .default = ..2
      )

      if (pipeline_datetime_round > check_datetime_round) {
        pipeline_sequence <- ..3
      } else {
        pipeline_sequence <- seq(pipeline_datetime_round, check_datetime_round, by = paste(..1, pipeline_unit))
      }

      cur_run <- utils::tail(pipeline_sequence, n = 1)
      is_scheduled_now <- check_datetime_round == cur_run
      next_run <- pipeline_datetime_round
      if (next_run < check_datetime_round) {
        next_run <- timechange::time_round(
          timechange::time_add(
            cur_run,
            second = max(orch_frequency_seconds, pipeline_frequency_seconds)
          ),
          unit = paste(orch_n, orch_unit)
        )
      }

      list(
        next_run = next_run,
        is_scheduled_now = is_scheduled_now
      )
    }
  )

  schedule_checks
}
