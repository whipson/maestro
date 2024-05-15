#' @maestroFrequency day
#' @maestroInterval 1
#' @maestroStartTime 2024-03-25 12:30:00
my_etl <- function() {

  # Extract data from random user generator
  raw_data <- httr2::request("https://randomuser.me/api/") |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)

  # Transform - get results and clean the names
  transformed <- raw_data$results |>
    janitor::clean_names()

  # Load - write to a location
  write.csv(transformed, file = paste0(tempfile(), "random_user_", Sys.Date(), ".csv"))
}
