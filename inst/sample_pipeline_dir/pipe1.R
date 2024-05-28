#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency 1 day
#' @maestroStartTime 2024-03-01 09:00:00
#' @maestroTz UTC
#'
#' @export
get_mtcars <- function() {
  Sys.sleep(0.02)
  mtcars
}

#' Multiply
#'
#' @maestroFrequency 1 month
#'
#' @export
wait <- function() {
  Sys.sleep(0.01)
}
