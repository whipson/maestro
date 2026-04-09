#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency 1 day
#' @maestroTz America/Halifax
get_mtcars <- function() {
  Sys.sleep(0.02)
  mtcars
}

#' Multiply
#'
#' @maestroFrequency 3 month
wait <- function() {
  Sys.sleep(0.01)
}

#' @maestroFrequency 1 week
weekly <- function() {
  1 + 1
}

#' @maestroFrequency 1 day
way_in_the_future <- function() {
  invisible()
}

#' @maestroFrequency weekly
weekly2 <- function() {
  1 + 1
}
