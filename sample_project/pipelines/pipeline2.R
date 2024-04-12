#' Simple mtcars print function
#'
#'
#' @batonFrequency week
#' @batonInterval 2
#' @batonStartTime 2024-03-11 09:00:00
#'
#' @export
write_data <- function(data) {
  write.csv(data, "~/Downloads/test_data.csv")
}

