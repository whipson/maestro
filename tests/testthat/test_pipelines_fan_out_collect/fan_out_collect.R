#' @maestroFrequency daily
numbers <- function() {
  1:3
}

#' @maestroInputs each(numbers)
multiply <- function(.input) {
  .input * 3
}

#' @maestroInputs collect(multiply)
add <- function(.input) {
  sum(unlist(.input))
}