#' @maestroInputs primary
with_inputs <- function(.input) {
  paste(.input, "then me")
}

#' @maestroFrequency daily
primary <- function() {
  "me first"
}
