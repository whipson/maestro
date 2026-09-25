#' @maestroFrequency daily
#' @maestro
rng_pipe <- function() {
  update_metric("draw", sample(1:10, 1))
  42
}
