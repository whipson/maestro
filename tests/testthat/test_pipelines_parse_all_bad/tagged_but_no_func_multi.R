#' @maestroFrequency
data <- iris |>
  dplyr::filter() |>
  dplyr::summarise()

#' @maestroFrequency
data |>
  head(n = 6)

#' @maestroFrequency
this_one_is_good <- function() {
  # But the fact that there are bad ones above makes it bad
  iris
}
