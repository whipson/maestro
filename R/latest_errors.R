#' Retrieve latest maestro parsing errors from
#'
#' @return error and trace output
#' @export
latest_parsing_errors <- function() {
  maestro_pkgenv$latest_parsing_errors
}

latest_runtime_errors <- function() {
  maestro_pkgenv$latest_runtime_errors
}
