#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @batonFrequency daily
#' @batonInterval 1
#' @batonStartTime 2024-03-01 09:00:00
#' @batonTz UTC
#'
#' @export
get_mtcars <- function() {
  Sys.sleep(0.2)
  mtcars
}

#' Multiply
#'
#' @batonFrequency monthly
#' @batonInterval 3
#'
#' @export
wait <- function() {
  Sys.sleep(0.1)
}
