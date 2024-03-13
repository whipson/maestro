########################################
# Pipeline 4 -- Daily GeoMet Climate Hourly
# Frequency: Daily
# Interval: 1
########################################

########################################
# SETUP
library(httr2)
library(sf)

rdate <- Sys.Date() - 1

# Access climate hourly via geomet api
req <- httr2::request("https://api.weather.gc.ca/collections/climate-hourly/items") |>
  httr2::req_url_query(
    lang = "en-CA",
    limit = 24,
    offset = 0,
    CLIMATE_IDENTIFIER = 8202251,
    LOCAL_DATE = rdate
  )

# Perform the request
resp <- req |>
  httr2::req_perform()

# Climate station response to data frame
df <- resp |>
  httr2::resp_body_string() |>
  sf::st_read(quiet = TRUE)

df
