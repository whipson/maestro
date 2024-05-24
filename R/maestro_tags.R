#' Maestro Tags
#'
#' maestro tags are roxygen2 comments for configuring the scheduling and execution
#' of pipelines.
#'
#' @md
#' @details
#'
#' maestro tags follow the format `#' @@maestroTagName`
#'
#' ### Tag List
#'
#' * maestroFrequency: Time unit for scheduling (e.g., day, week, month, etc.)
#' * maestroInterval: Number of time units between executions (e.g., 1, 2, 3)
#' * maestroLogLevel: Threshold for logging when logging is requested by orchestrator (e.g., INFO, WARN, ERROR, etc.)
#' * maestroSkip: Skips the pipeline when running orchestrator (presence of tag indicates skip)
#' * maestroStartTime: yyyy-MM-dd HH:MM:SS for the start time of the pipeline
#' * maestroTz: Timezone of the start time (e.g., UTC); see `OlsonNames()` for all timezones
#'
#' @name maestro_tags
NULL
