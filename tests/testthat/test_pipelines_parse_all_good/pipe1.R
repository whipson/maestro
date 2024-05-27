#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency day
#' @maestroInterval 1
#' @maestroStartTime 2024-03-01 09:00:00
#' @maestroTz UTC
#' @maestroLogLevel INFO
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
#' @maestroLogLevel warn
#'
#' @export
wait <- function() {
  Sys.sleep(0.01)
}

#' Add
#'
#' @maestroFrequency month
#' @maestroInterval 3
#' @maestroStartTime 1970-01-01
#'
#' @export
add <- function() {
  invisible()
}

#' Something
#'
#' @maestroFrequency month
#' @maestroInterval 3
#' @maestroStartTime 1970-01-01 00:00:00 ADT
#'
#' @export
something <- function() {
  invisible()
}
