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
    pipeline_datetime,
    pipeline_hours = 0:23,
    pipeline_days_of_week = 1:7,
    pipeline_days_of_month = 1:31,
    pipeline_months = 1:12
  ) {

  orch_string <- paste(orch_n, orch_unit)
  orch_frequency_seconds <- convert_to_seconds(orch_string)
  check_datetime_round <- timechange::time_round(check_datetime, unit = orch_string)

  schedule_checks <- purrr::pmap(
    list(pipeline_n, pipeline_unit, pipeline_datetime, pipeline_hours,
         pipeline_days_of_week, pipeline_days_of_month,
         pipeline_months),
    ~{
      pipeline_datetime_round <- timechange::time_round(..3, unit = orch_string)

      pipeline_sequence <- get_pipeline_run_sequence(
        pipeline_n = ..1,
        pipeline_unit = ..2,
        pipeline_datetime = pipeline_datetime_round,
        check_datetime = check_datetime_round,
        pipeline_hours = ..4,
        pipeline_days_of_week = ..5,
        pipeline_days_of_month = ..6,
        pipeline_months = ..7
      )

      cur_run <- utils::tail(pipeline_sequence, n = 1)
      is_scheduled_now <- check_datetime_round == cur_run

      future_sequence <- get_pipeline_run_sequence(
        pipeline_n = ..1,
        pipeline_unit = ..2,
        pipeline_datetime = cur_run,
        check_datetime = cur_run + lubridate::years(1),
        pipeline_hours = ..4,
        pipeline_days_of_week = ..5,
        pipeline_days_of_month = ..6,
        pipeline_months = ..7
      )

      next_run <- purrr::pluck(future_sequence, 2)

      if (is.null(next_run)) {
        pipeline_frequency_seconds <- convert_to_seconds(paste(..1, ..2))

        next_run <- timechange::time_round(
          timechange::time_add(
            cur_run,
            second = max(orch_frequency_seconds, pipeline_frequency_seconds)
          ),
          unit = orch_string
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
