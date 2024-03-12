########################################
# Pipeline 5 -- Monthly GeoMet Climate Monthly
# Frequency: Monthly
# Interval: 1
########################################

########################################
# SETUP
library(httr2)
library(sf)

pdate <- lubridate::floor_date(lubridate::rollback(Sys.Date(), roll_to_first = FALSE), unit = "months")
pmonth <- lubridate::month(pdate)
pyear <- lubridate::year(pdate)


# Access climate monthly via geomet api
req <- httr2::request("https://api.weather.gc.ca/collections/climate-daily/items") |>
  httr2::req_url_query(
    lang = "en-CA",
    limit = 31,
    offset = 0,
    CLIMATE_IDENTIFIER = 8202251,
    LOCAL_MONTH = pmonth,
    LOCAL_YEAR = pyear
  )

# Perform the request
resp <- req |>
  httr2::req_perform()

# Climate station response to data frame
df <- resp |>
  httr2::resp_body_string() |>
  sf::st_read(quiet = TRUE)

df
