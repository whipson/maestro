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
#'  | tagName          | description                                                         | value             | examples (comma sep.)           | default             |
#'  |------------------|---------------------------------------------------------------------|-------------------|---------------------------------|---------------------|
#'  | maestroFrequency | Time unit for scheduling                                            | string            | 1 hour, 3 days, 5 weeks         | 1 day               |
#'  | maestroLogLevel  | Threshold for logging when logging is requested                     | string            | INFO, WARN, ERROR               | INFO                |
#'  | maestroSkip      | Skips the pipeline when running (presence of tag indicates to skip) | n/a               |                                 |                     |
#'  | maestroStartTime | Start time of the pipeline; sets the point in time for recurrence   | date or timestamp | 1970-01-01 00:00:00, 2024-03-28 | 1970-01-01 00:00:00 |
#'  | maestroTz        | Timezone of the start time                                          | string            | UTC, America/Halifax            | UTC                 |
#'
#' @name maestro_tags
NULL
