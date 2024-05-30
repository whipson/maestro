# maestroFrequency ----------------------------------------------------------
#' @importFrom roxygen2 roclet_output roclet_process roxy_tag_parse
#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroFrequency <- function(x) {

  # Cast lower and trim whitespace
  x$raw <- x$raw |>
    tolower() |>
    trimws()

  if (x$raw == "") {
    x$val <- "1 day"
  } else {

    tryCatch({
      # Try to parse it using our function
      parse_rounding_unit(x$raw)

      # Try to parse using timechange
      timechange::time_round(Sys.time(), unit = x$raw)

      x$val <- x$raw
    }, error = \(e) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroFrequency `{x$raw}`.
          Must have a format of [number] [units] (e.g., 1 day, 2 weeks, 4 months, etc)"
        )
      )
      return()
    })
  }

  x
}

maestroFrequency_roclet <- function() {
  roxygen2::roclet("maestroFrequency")
}

#' @exportS3Method
roclet_process.roclet_maestroFrequency <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroFrequency")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @exportS3Method
roclet_output.roclet_maestroFrequency <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}

# maestroStartTime ----------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroStartTime <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    x$val <- "1970-01-01 00:00:00"
  } else {
    tryCatch({
      x_ts <- as.POSIXct(x$raw) # check if coercible
      x_ts <- strftime(x_ts, format = "%Y-%m-%d %H:%M:%S")
      x$val <- x_ts
    }, error = \(e) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroStartTime `{x$raw}`.
          Must be a timestamp formatted as yyyy-mm-dd HH:MM:SS"
        )
      )
      return()
    })
  }

  x
}

maestroStartTime_roclet <- function() {
  roxygen2::roclet("maestroStartTime")
}

#' @exportS3Method
roclet_process.roclet_maestroStartTime <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroStartTime")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @exportS3Method
roclet_output.roclet_maestroStartTime <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# maestroTz -----------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroTz <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    x$val <- "UTC"
  } else {
    if(!x$raw %in% OlsonNames()) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroTz `{x$raw}`.
          Must be a valid timezone string. See valid tzs with `OlsonNames()`"
        )
      )
      return()
    }
    x$val <- x$raw
  }
  x
}

maestroTz_roclet <- function() {
  roxygen2::roclet("maestroTz")
}

#' @exportS3Method
roclet_process.roclet_maestroTz <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroTz")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @exportS3Method
roclet_output.roclet_maestroTz <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# maestroSkip ---------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroSkip <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw != "") {
    roxygen2::roxy_tag_warning(
      x,
      "Invalid maestroSkip. Use tag name with no value to indicate pipeline should be skipped (e.g., `#' @maestroSkip`)."
    )
  }

  x$val <- TRUE
  x
}

maestroSkip_roclet <- function() {
  roxygen2::roclet("maestroSkip")
}

#' @exportS3Method
roclet_process.roclet_maestroSkip <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroSkip")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}


#' @exportS3Method
roclet_output.roclet_maestroSkip <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}

# maestroLogLevel ----------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroLogLevel <- function(x) {

  log_levels <- c(
    "INFO", "WARN", "ERROR", "OFF", "FATAL", "SUCCESS", "DEBUG", "TRACE"
  )

  x$raw <- x$raw |>
    toupper() |>
    trimws()

  if (x$raw == "") {
    x$val <- "INFO"
  } else if (x$raw %in% log_levels) {
    x$val <- x$raw
  } else {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Invalid maestroLogLevel `{x$raw}`.
        Must be one of {paste(log_levels, collapse = ', ')}"
      )
    )
    return()
  }

  x
}

maestroLogLevel_roclet <- function() {
  roxygen2::roclet("maestroLogLevel")
}

#' @exportS3Method
roclet_process.roclet_maestroLogLevel <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroLogLevel")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @exportS3Method
roclet_output.roclet_maestroLogLevel <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}

