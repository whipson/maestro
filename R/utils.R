#' Round time formatted
#'
#' @param check_datetime POSIXct object
#' @param unit_value unit to round to
#'
#' @return character
round_time <- function(check_datetime, unit_value) {
  format(
    as.POSIXct(lubridate::round_date(check_datetime, unit = unit_value), format = "%H:%M"),
    "%H:%M:%S"
  )
}
