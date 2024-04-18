#' @maestroFrequency day
#' @maestroInterval 1
#' @maestroStartTime 2024-04-11 15:30:00
#' @maestroTz America/Halifax

etl <- function() {

  library(dplyr)
  library(janitor)
  library(readr)

  file_sys_time <- as.integer(Sys.time())
  outfile_name <- paste0("active_hurricanes_", file_sys_time, ".csv")
  out_path <- paste0("output/", outfile_name)

  # Extract data from source
  extract <- function() {
    readr::read_csv("https://www.ncei.noaa.gov/data/international-best-track-archive-for-climate-stewardship-ibtracs/v04r00/access/csv/ibtracs.ACTIVE.list.v04r00.csv")
  }

  # Transform and clean data frame
  transform <- function() {
    extract() |>
      dplyr::filter(!is.na(SID)) |>
      dplyr::select(SEASON:LON, DIST2LAND, LANDFALL, USA_WIND, USA_PRES) |>
      dplyr::mutate(insert_time = Sys.time()) |>
      janitor::clean_names()
  }

  # Load data to local drive
  load <- function() {
    transform() |> print()
  }

  load()
}


