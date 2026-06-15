#' @maestroFrequency daily
letter_a <- function() {
  'a'
}

#' @maestroFrequency daily
letter_b <- function() {
  'b'
}

#' @maestroInputs collect(letter_a, letter_b)
ab <- function(.input) {
  paste0(.input$letter_a, .input$letter_b)
}

#' @maestroInputs ab
ab_upper <- function(.input) {
  toupper(.input)
}
