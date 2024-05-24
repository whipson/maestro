#' Check which pipelines are scheduled to run and when next pipelines will run
#'
#' @param .data data.frame with pipeline name, interval, frequency, and start datetime
#' @param orch_interval a numeric value representing how often the orchestration runs
#' @param orch_frequency unit of how often the orchestration runs (i.e. min, hour, day, month, etc.)
#' @param check_datetime datetime used to check against the pipeline start datetime
#'
#' @return list
#'
check_pipelines <- function(.data, orch_interval, orch_frequency, check_datetime) {

  schedule_checks <- purrr::pmap(
    list(.data$interval, .data$frequency, .data$start_time),
    ~{
      check_pipeline_next_schedule(orch_interval, orch_frequency, check_datetime, ..1, ..2, ..3)
    }
  )

  schedule_checks
}
