#' Simple mtcars print function
#'
#'
#' @maestroFrequency week
#' @maestroInterval 2
#' @maestroStartTime 2024-03-11 09:00:00
#'
#' @export
write_data <- function(data) {
  write.csv(data, "~/Downloads/test_data.csv")
}

