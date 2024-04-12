#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @batonFrequency day
#' @batonInterval 1
#' @batonStartTime 2024-03-01 09:00:00
#' @batonTz UTC
#'
#' @export
get_mtcars <- function() {
  mtcars
}

#' Multiply
#'
#' @batonFrequency month
#' @batonInterval 3
#'
#' @export
multiply <- function(val, by) {
  val * by
}

#' Bad
#'
#' @batonTz BLA
something_else <- function() {

}
