#' @maestroFrequency daily
numbers <- function() {
  1:3
}

#' @maestroInputs numbers
#' @maestroMap
multiply <- function(.input) {
  .input * 3
}
  
#' @maestroInputs multiply
add_2 <- function(.input) {
  .input + 2
}