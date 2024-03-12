#' round_time
#'
#' @param check_datetime
#' @param unit_value
#'
#' @return
#'
#' @examples
round_time <- function(check_datetime, unit_value) {
  format(
    as.POSIXct(lubridate::round_date(check_datetime, unit = unit_value), format = "%H:%M"),
    "%H:%M:%S"
  )
}
