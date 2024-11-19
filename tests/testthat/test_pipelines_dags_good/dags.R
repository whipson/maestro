# Simple 1 -> 1 -----------------------------------------------------------
#' @maestroInputs primary
with_inputs <- function(.input) {
  paste("input message is:", .input)
}

#' @maestroFrequency daily
#' @maestroOutputs with_inputs
primary <- function() {
  "hello"
}


# Tree with Two Branches x 2 ----------------------------------------------
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

# Split and Unite ---------------------------------------------------------

#' @maestroOutputs high_road low_road
start <- function() {
  c("a", "A")
}

#' @maestroInputs start
#' @maestroOutputs end
high_road <- function(.input) {
  toupper(.input)
}

#' @maestroInputs start
#' @maestroOutputs end
low_road <- function(.input) {
  tolower(.input)
}

#' @maestroInputs high_road low_road
end <- function(.input) {
  c(.input, "b")
}


