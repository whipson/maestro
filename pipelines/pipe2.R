#' @maestroFrequency day
#' @maestroInterval 1
#' @maestroStartTime 2024-03-01 09:00:00
#' @maestroTz UTC
#'
#' @export
multi_rng <- function() {
  replicate(10000, sample(1:100))
}
