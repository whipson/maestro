custom_fun <- function(val1, val2) {
  paste(val1, val2)
}

#' @maestroFrequency 1 minute
pipe <- function() {
  custom_fun(1, 2)
}
