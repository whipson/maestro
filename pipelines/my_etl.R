#' Example ETL pipeline
#' @maestroFrequency daily
#' @maestroStartTime 12:30:00
#' @maestroTz America/Halifax
my_etl <- function() {

  # Pretend we're getting data from a source
  message("Get data")
  extracted <- mtcars

  # Transform
  message("Transforming")
  transformed <- extracted |>
    dplyr::mutate(hp_deviation = hp - mean(hp))

  # Load - write to a location
  message("Writing")
  # write.csv(transformed, file = paste0("transformed_mtcars_", Sys.Date(), ".csv"))
}
