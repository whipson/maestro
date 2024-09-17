#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency 1 day
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
#' @maestroFrequency 3 month
#' @maestroLogLevel warn
#'
#' @export
wait <- function() {
  Sys.sleep(0.01)
}

#' Add
#'
#' @maestroFrequency 3 month
#' @maestroStartTime 1970-01-01
#'
#' @export
add <- function() {
  invisible()
}

#' Something
#'
#' @maestroFrequency 3 month
#' @maestroStartTime 1970-01-01 00:00:00 ADT
#'
#' @export
something <- function() {
  invisible()
}

#' Daily
#'
#' @maestroFrequency daily
#' @maestroStartTime 1970-01-01 00:00:00 ADT
#'
#' @export
something2 <- function() {
  invisible()
}
