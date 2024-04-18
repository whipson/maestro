#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency day
#' @maestroInterval 1
#' @maestroStartTime 2024-03-01 09:00:00
#' @maestroTz UTC
#'
#' @export
get_mtcars <- function() {
  mtcars
}

#' Multiply
#'
#' @maestroFrequency month
#' @maestroInterval 3
#'
#' @export
multiply <- function(val, by) {
  val * by
}
