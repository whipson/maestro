#' @maestroInputs primary
also_with_inputs <- function(.input) {
  paste(.input, "don't forget me")
}

#' @maestroInputs primary
with_inputs <- function(.input) {
  paste(.input, "then me")
}

#' @maestroFrequency daily
primary <- function() {
  "me first"
}
