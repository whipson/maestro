########################################
# Pipeline 3 -- Hourly GeoMet AQHI forecasts
# Frequency: Hourly
# Interval: 1
########################################

########################################
# SETUP
library(httr2)
library(sf)


# Access climate hourly via geomet api
req <- httr2::request("https://api.weather.gc.ca/collections/aqhi-forecasts-realtime/items") |>
  httr2::req_url_query(
    lang = "en-CA",
    limit = 1,
    offset = 0,
    location_name_en = "Halifax"
  )

# Perform the request
resp <- req |>
  httr2::req_perform()

# Climate station response to data frame
df <- resp |>
  httr2::resp_body_string() |>
  sf::st_read(quiet = TRUE)

df
