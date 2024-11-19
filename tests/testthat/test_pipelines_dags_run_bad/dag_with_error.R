# Simple 1 -> 1 -----------------------------------------------------------
#' @maestroInputs get_num
multiply <- function(.input) {
  .input * 4
}

#' @maestroFrequency daily
#' @maestroOutputs multiply
get_num <- function() {
  stop("oops")
}
