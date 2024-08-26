#' \code{maestro} package
#'
#' Lightweight pipeline orchestration in R
#'
#' Documentation: \href{https://github.com/whipson/maestro}{GitHub}
#'
#' @name maestro
"_PACKAGE"

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(
  c("frequency", "start_time", "tz", "skip", "log_level", "is_scheduled_now",
    "next_run", "frequency_n", "frequency_unit", "errors", "pipe_name",
    "script_path", "invoked", "success", "pipeline_started", "pipeline_ended",
    "messages", "run_time", "run_date", "run_time_15min", "n_runs",
    "hours", "days_of_week", "days_of_month", "days", "months")
)
