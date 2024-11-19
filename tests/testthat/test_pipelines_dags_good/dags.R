#' @maestroInputs primary
with_inputs <- function(.input) {
  message(.input)
}

#' @maestroFrequency daily
#' @maestroOutputs with_inputs
primary <- function() {
  "hello"
}
