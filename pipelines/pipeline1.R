########################################
# Pipline 1 -- Daily GeoMet Climate Daily
# Frequency: Daily
# Interval: 1
########################################

########################################
# SETUP
library(httr2)
library(sf)


# Access climate hourly via geomet api
req <- httr2::request("https://api.weather.gc.ca/collections/climate-daily/items") |>
  httr2::req_url_query(
    lang = "en-CA",
    limit = 10,
    offset = 0,
    CLIMATE_IDENTIFIER = 8202251
  )

# Perform the request
resp <- req |>
  httr2::req_perform()

# Climate station response to data frame
df <- resp |>
  httr2::resp_body_string() |>
  sf::st_read(quiet = TRUE)

df
