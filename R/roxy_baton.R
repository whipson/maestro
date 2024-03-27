# batonFrequency ----------------------------------------------------------
#' @export
roxy_tag_parse.roxy_tag_batonFrequency <- function(x) {

  # Cast lower and trim whitespace
  x$raw <- x$raw |>
    tolower() |>
    trimws()

  if (x$raw == "") {
    x$val <- "daily"
  } else if (x$raw %in% c("minutely", "hourly", "daily", "weekly",
                          "monthly", "quarterly", "yearly")) {
    x$val <- x$raw
  } else {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Invalid batonFrequency `{x$raw}`.
        Must be one of 'minutely', 'hourly', 'daily', 'weekly',
        'monthly', 'quarterly', 'yearly'"
      )
    )
    return()
  }
  x
}

#' @export
batonFrequency_roclet <- function() {
  roxygen2::roclet("batonFrequency")
}

#' @export
roclet_process.roclet_batonFrequency <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonFrequency")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @export
roclet_output.roclet_batonFrequency <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# batonInterval -----------------------------------------------------------
#' @export
roxy_tag_parse.roxy_tag_batonInterval <- function(x) {

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
          "Invalid batonInterval `{x$raw}`.
          Must be a positive, non-zero integer value"
        )
      )
      return()
    })
  }

  x
}

#' @export
batonInterval_roclet <- function() {
  roxygen2::roclet("batonInterval")
}

#' @export
roclet_process.roclet_batonInterval <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonInterval")
  list(
    val = as.integer(tags$val),
    node = blocks[[1]]$object$topic
  )
}

#' @export
roclet_output.roclet_batonInterval <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# batonStartTime ----------------------------------------------------------

#' @export
roxy_tag_parse.roxy_tag_batonStartTime <- function(x) {

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
          "Invalid batonStartTime `{x$raw}`.
          Must be a timestamp formatted as yyyy-mm-dd HH:MM:SS"
        )
      )
      return()
    })
  }

  x
}

#' @export
batonStartTime_roclet <- function() {
  roxygen2::roclet("batonStartTime")
}

#' @export
roclet_process.roclet_batonStartTime <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonStartTime")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @export
roclet_output.roclet_batonStartTime <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# batonTz -----------------------------------------------------------------

#' @export
roxy_tag_parse.roxy_tag_batonTz <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    x$val <- "UTC"
  } else {
    if(!x$raw %in% OlsonNames()) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid batonTz `{x$raw}`.
          Must be a valid timezone string. See valid tzs with `OlsonNames()`"
        )
      )
      return()
    }
    x$val <- x$raw
  }
  x
}

#' @export
batonTz_roclet <- function() {
  roxygen2::roclet("batonTz")
}

#' @export
roclet_process.roclet_batonTz <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonTz")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @export
roclet_output.roclet_batonTz <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}


# batonSkip ---------------------------------------------------------------

#' @export
roxy_tag_parse.roxy_tag_batonSkip <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw != "") {
    roxygen2::roxy_tag_warning(
      x,
      "Invalid batonSkip. Use tag name with no value to indicate pipeline should be skipped (e.g., `#' @batonSkip`)."
    )
  }

  x$val <- TRUE
  x
}

#' @export
batonSkip_roclet <- function() {
  roxygen2::roclet("batonSkip")
}

#' @export
roclet_process.roclet_batonSkip <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonSkip")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

#' @export
roclet_output.roclet_batonSkip <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}
