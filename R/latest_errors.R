#' Retrieve latest baton parsing errors from
#'
#' @return error and trace output
#' @export
latest_parsing_errors <- function() {
  baton_pkgenv$latest_parsing_errors
}

latest_runtime_errors <- function() {
  baton_pkgenv$latest_runtime_errors
}
