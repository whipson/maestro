#' @maestroFrequency daily
#' @maestroStartTime 09:00:00
#' @maestroTz America/Halifax
multi_rng <- function() {
  replicate(10000, sample(1:100))
}
