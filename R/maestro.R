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
    "next_run")
)
