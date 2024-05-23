#' Simple mtcars print function
#'
#' This is a function that runs every hour starting at
#' 2024-03-01 09:00:00
#'
#' @maestroFrequency day
#' @maestroLogLevel INFO
#'
#' @export
get_mtcars <- function() {
  Sys.sleep(0.02)
  mtcars
}
