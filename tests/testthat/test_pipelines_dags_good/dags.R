#' @maestroInputs primary
with_inputs <- function(.input) {
  paste("input message is:", .input)
}

#' @maestroFrequency daily
#' @maestroOutputs with_inputs
primary <- function() {
  "hello"
}

#' @maestroFrequency daily
#' @maestroOutputs branch1 branch2
trunk <- function() {
  1
}

#' @maestroInputs trunk
#' @maestroOutputs subbranch1
branch1 <- function(.input) {
  .input * 1
}

#' @maestroInputs trunk
#' @maestroOutputs subbranch2
branch2 <- function(.input) {
  .input * 2
}

#' @maestroInputs branch1
subbranch1 <- function(.input) {
  .input * 2
}

#' @maestroInputs branch2
subbranch2 <- function(.input) {
  .input * 3
}
