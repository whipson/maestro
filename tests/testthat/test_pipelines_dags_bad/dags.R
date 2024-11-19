#' @maestroInputs im_not_here
missing_inputs <- function(.input) {

}

# Loop --------------------------------------------------------------------
#' @maestroOutputs loopy2
loopy1 <- function(.input = 1) {
  .input * 2
}

#' @maestroOutputs loopy3
#' @maestroInputs loopy1
loopy2 <- function(.input = 1) {
  .input * 3
}

#' @maestroOutputs loopy2
#' @maestroInputs loopy2
loopy3 <- function(.input = 1) {
  .input * 4
}
