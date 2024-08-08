#' Check which pipelines are scheduled to run and when next pipelines will run
#'
#' @inheritParams get_pipeline_run_sequence
#' @param orch_unit unit of time for the orchestrator
#' @param orch_n number of units for the orchestrator
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
      pipeline_datetime_round <- timechange::time_round(..3, unit = paste(orch_n, orch_unit))

      pipeline_sequence <- get_pipeline_run_sequence(
        ..1, ..2, pipeline_datetime_round, check_datetime_round
      )

      cur_run <- utils::tail(pipeline_sequence, n = 1)
      is_scheduled_now <- check_datetime_round == cur_run
      next_run <- pipeline_datetime_round
      if (next_run < check_datetime_round) {
        pipeline_frequency_seconds <- convert_to_seconds(paste(..1, ..2))

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
