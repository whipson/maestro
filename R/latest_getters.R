#' Retrieve latest maestro parsing errors
#'
#' Gets the latest parsing errors following use of `build_schedule()`.
#'
#' @return error and trace output
#' @export
last_parsing_errors <- function() {
  maestro_pkgenv$last_parsing_errors
}

#' Retrieve latest maestro runtime errors
#'
#' Gets the latest runtime errors following use of `run_schedule()`
#'
#' @return error message
#' @export
last_runtime_errors <- function() {
  maestro_pkgenv$last_runtime_errors
}

#' Retrieve latest maestro runtime warnings
#'
#' Gets the latest runtime warnings following use of `run_schedule()`
#'
#' @return warning messages
#' @export
last_runtime_warnings <- function() {
  maestro_pkgenv$last_runtime_warnings
}

#' Retrieve latest maestro runtime messages
#'
#' Gets the latest runtime messages following use of `run_schedule()`
#'
#' @return messages
#' @export
last_runtime_messages <- function() {
  maestro_pkgenv$last_runtime_messages
}
