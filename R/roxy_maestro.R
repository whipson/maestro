# maestroFrequency ----------------------------------------------------------
#' @importFrom roxygen2 roclet_output roclet_process roxy_tag_parse
#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroFrequency <- function(x) {

  # Cast lower and trim whitespace
  x$raw <- x$raw |>
    tolower() |>
    trimws()

  if (x$raw == "") {
    x$val <- "day"
  } else if (x$raw %in% c("minute", "hour", "day", "week",
                          "month", "quarter", "year")) {
    x$val <- x$raw
  } else {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Invalid maestroFrequency `{x$raw}`.
        Must be one of 'minute', 'hour', 'day', 'week',
        'month', 'quarter', 'year'"
      )
    )
    return()
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


# maestroInterval -----------------------------------------------------------
#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroInterval <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    x$raw <- "1"
  } else {
    # If coercion to integer fails, trigger warning and empty return
    tryCatch({
      x_int <- as.integer(x$raw)
      if (x_int <= 0) warning()
      x$val <- x_int
    }, warning = \(w) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroInterval `{x$raw}`.
          Must be a positive, non-zero integer value"
        )
      )
      return()
    })
  }

  x
}

maestroInterval_roclet <- function() {
  roxygen2::roclet("maestroInterval")
}

#' @exportS3Method
roclet_process.roclet_maestroInterval <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroInterval")
  list(
    val = as.integer(tags$val),
    node = blocks[[1]]$object$topic
  )
}

#' @exportS3Method
roclet_output.roclet_maestroInterval <- function(x, results, base_path, ...) {
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
