#' @maestroFrequency day
#' @maestroLogLevel WARN
pipe3 <- function() {
  message("Hide me")

  warning("Oops")
  iris
}

#' @maestroInterval 10
#' @maestroLogLevel WARN
pipe4 <- function() {
  message("Hide me too")

  warning("Another oops")
  rnorm(10)
}
