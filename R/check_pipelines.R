#' Check which pipelines are scheduled to run and when next pipelines will run
#'
#' @param .data data.frame with pipeline name, frequency, and start datetime
#' @param orch_frequency number of seconds representing the frequency of orchestrator
#' @param check_datetime datetime used to check against the pipeline start datetime
#'
#' @return list
#'
check_pipelines <- function(.data, orch_frequency, check_datetime) {

  schedule_checks <- purrr::pmap(
    list(.data$frequency, .data$start_time),
    ~{
      check_pipeline_next_schedule(
        orch_frequency = orch_frequency,
        check_datetime = check_datetime,
        pipeline_seconds = ..1,
        pipeline_datetime = ..2
      )
    }
  )

  schedule_checks
}
