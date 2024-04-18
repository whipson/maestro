#' Retrieve latest maestro parsing errors
#'
#' @return error and trace output
#' @export
latest_parsing_errors <- function() {
  maestro_pkgenv$latest_parsing_errors
}

#' Retrieve latest maestro runtime errors
#'
#' @return error message
#' @export
latest_runtime_errors <- function() {
  maestro_pkgenv$latest_runtime_errors
}

#' Retrieve latest maestro runtime warnings
#'
#' @return warning messages
#' @export
latest_runtime_warnings <- function() {
  maestro_pkgenv$latest_runtime_warnings
}
