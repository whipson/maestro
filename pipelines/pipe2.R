#' @maestroFrequency daily
#' @maestroStartTime 09:00:00
#' @maestroTz UTC
multi_rng <- function() {
  replicate(10000, sample(1:100))
}
