#' Check monthly
#'
#' @param check_datetime
#' @param current_datetime
#' @param unit_value
#'
#' @return
#' @examples
check_monthly <- function(check_datetime, current_datetime, unit_value) {
  if (lubridate::day(current_datetime) == lubridate::day(check_datetime)) {
    if (round_time(current_datetime, unit_value) == round_time(check_datetime, unit_value)) {
      print("Date and time are the same")
    } else {
      print("Date is the same, time is different")
    }
  } else {
    "Date and time are not the same"
  }
}


#' Check daily
#'
#' @param check_datetime
#' @param current_datetime
#' @param unit_value
#'
#' @return
#' @examples
check_daily <- function(check_datetime, current_datetime, unit_value) {
  if (round_time(current_datetime, unit_value) == round_time(check_datetime, unit_value)){
    print("Time is the same")
  } else {
    print("Time is different")
  }
}


#' Check houlry
#'
#' @param check_datetime
#' @param current_datetime
#' @param unit_value
#'
#' @return
#' @examples
check_hourly <- function(check_datetime, current_datetime, unit_value) {
  if (round_minute(current_datetime, "15 mins") == round_time(check_datetime, "15 mins")){
    print("Minute is the same")
  } else {
    print("Minute is different")
  }
}
