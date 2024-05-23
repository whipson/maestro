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
  Sys.sleep(0.02)
  mtcars
}

#' Multiply
#'
#' @maestroFrequency month
#' @maestroInterval 3
#'
#' @export
wait <- function() {
  Sys.sleep(0.01)
}

#' @maestroFrequency week
#' @maestroInterval 1
#'
#' @export
weekly <- function() {
  1 + 1
}

#' @maestroStartTime 5000-12-12 10:10:10
way_in_the_future <- function() {
  invisible()
}
