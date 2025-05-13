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

  } else if (grepl("^[0-9]", x$raw)) {

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
          Must have a format of [number] [units] (e.g., 1 day, 1 week, 4 months, etc)
          or one of hourly, daily, weekly, etc."
        )
      )
      return()
    })

  } else {

    if (!x$raw %in% c("hourly", "daily", "weekly", "biweekly", "monthly", "quarterly", "yearly")) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroFrequency `{x$raw}`.
          Must have a format of [number] [units] (e.g., 1 day, 1 week, 4 months, etc)
          or one of hourly, daily, weekly, etc."
        )
      )
      return()
    }

    x$val <- x$raw
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

# maestroStartTime ----------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroStartTime <- function(x) {

  x$raw <- x$raw |>
    trimws()

  tryCatch({

    if (x$raw == "") {
      x$val <- "1970-01-01 00:00:00"
    } else if (nchar(x$raw) == 8) {
      x_ts <- as.POSIXct(x$raw, format = "%H:%M:%S") # check if coercible
      x$val <- x$raw
    } else {
      x_ts <- as.POSIXct(x$raw) # check if coercible
      x_ts <- strftime(x_ts, format = "%Y-%m-%d %H:%M:%S")
      x$val <- x_ts
    }

  }, error = \(e) {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Invalid maestroStartTime `{x$raw}`.
          Must be a timestamp formatted as yyyy-mm-dd HH:MM:SS or HH:MM:SS"
      )
    )
    return()
  })


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

# maestroHours --------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroHours <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw != "") {
    x_sep <- tryCatch({
      as.numeric(strsplit(x$raw, "\\s+")[[1]])
    }, warning = function(w) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroHours `{x$raw}`.
        Must be one or more integers [0-23] separated by spaces (e.g., 1 4 7)"
        )
      )
      return()
    })

    # Check for values [0-23]
    if (!all(x_sep %in% 0:23)) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroHours `{x$raw}`.
        Must be one or more integers [0-23] separated by spaces (e.g., 1 4 7)"
        )
      )
      return()
    }

    x$val <- x_sep
  }

  x
}

maestroHours_roclet <- function() {
  roxygen2::roclet("maestroHours")
}

#' @exportS3Method
roclet_process.roclet_maestroHours <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroHours")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

# maestroDays --------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroDays <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw != "") {

    x_sep <- strsplit(x$raw, "\\s+")[[1]]

    if (all(grepl("[0-9]", x_sep))) {

      x_sep <- as.numeric(x_sep)

      # Check for values [1-31]
      if (!all(x_sep %in% 1:31)) {
        roxygen2::roxy_tag_warning(
          x,
          glue::glue(
            "Invalid maestroDays `{x$raw}`.
            All must be either integers [1-31] or values Mon, Tue, etc. separated by spaces"
          )
        )
        return()
      }

    } else if (all(x_sep %in% c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) {

      x_sep <- factor(x_sep, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))

    } else {

      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroDays `{x$raw}`.
            All must be either integers [1-31] or values Mon, Tue, etc. separated by spaces"
        )
      )
      return()
    }
  }

  x$val <- x_sep

  x
}

maestroDays_roclet <- function() {
  roxygen2::roclet("maestroDays")
}

#' @exportS3Method
roclet_process.roclet_maestroDays <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroDays")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

# maestroMonths -----------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroMonths <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw != "") {
    x_sep <- tryCatch({
      as.numeric(strsplit(x$raw, "\\s+")[[1]])
    }, warning = function(w) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroMonths `{x$raw}`.
        Must be one or more integers [1-12] separated by spaces (e.g., 1 6 12)"
        )
      )
      return()
    })

    # Check for values [1-12]
    if (!all(x_sep %in% 1:12)) {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroMonths `{x$raw}`.
        Must be one or more integers [1-12] separated by spaces (e.g., 1 6 12)"
        )
      )
      return()
    }

    x$val <- x_sep
  }

  x
}

maestroMonths_roclet <- function() {
  roxygen2::roclet("maestroMonths")
}

#' @exportS3Method
roclet_process.roclet_maestroMonths <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroMonths")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

# maestroInputs -----------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroInputs <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Empty maestroInputs. If pipeline doesn't take inputs, remove maestroInputs tag."
      )
    )
    return(x)
  }

  x$val <- strsplit(x$raw, "\\s+")[[1]]

  x
}

maestroInputs_roclet <- function() {
  roxygen2::roclet("maestroInputs")
}

#' @exportS3Method
roclet_process.roclet_maestroInputs <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroInputs")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

# maestroOutputs ----------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroOutputs <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Empty maestroOutputs. If pipeline doesn't take inputs, remove maestroOutputs tag."
      )
    )
    return(x)
  }

  x$val <- strsplit(x$raw, "\\s+")[[1]]

  x
}

maestroOutputs_roclet <- function() {
  roxygen2::roclet("maestroOutputs")
}

#' @exportS3Method
roclet_process.roclet_maestroOutputs <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroOutputs")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}


# maestro -----------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestro <- function(x) {
  x$val <- TRUE
  x
}

maestro_roclet <- function() {
  roxygen2::roclet("maestro")
}

#' @exportS3Method
roclet_process.roclet_maestro <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestro")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}


# maestroPriority ---------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroPriority <- function(x) {

  x$raw <- x$raw |>
    trimws()

  if (x$raw == "") {
    roxygen2::roxy_tag_warning(
      x,
      "Empty maestroPriority. If pipeline doesn't have a specified priority remove maestroPriority tag."
    )
    return(x)
  } else {
    if (!grepl("^\\d+$", x$raw) || x$raw == "0") {
      roxygen2::roxy_tag_warning(
        x,
        glue::glue(
          "Invalid maestroPriority `{x$raw}`.
          Must be a single positive integer from 1 on."
        )
      )
      return(x)
    }
    x$val <- x$raw
  }

  x
}

maestroPriority_roclet <- function() {
  roxygen2::roclet("maestroPriority")
}

#' @exportS3Method
roclet_process.roclet_maestroPriority <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroPriority")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}


# maestroFlags --------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroFlags <- function(x) {

  x$raw <- x$raw |>
    trimws()

  x_sep <- strsplit(x$raw, "\\s+")[[1]]
  x$val <- x_sep
  x
}

maestroFlags_roclet <- function() {
  roxygen2::roclet("maestroFlags")
}

#' @exportS3Method
roclet_process.roclet_maestroFlags <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "maestroFlags")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}


# maestroLabel ------------------------------------------------------------

#' @exportS3Method
roxy_tag_parse.roxy_tag_maestroLabel <- function(x) {

  x$raw <- x$raw |>
    trimws()

  x_sep <- strsplit(x$raw, "\\s+")[[1]]
  if (length(x_sep) != 2) {
    roxygen2::roxy_tag_warning(
      x,
      "Invalid maestroLabel. Should follow the format `#' @maestroLabel key value`."
    )
    return(x)
  }
  x$val <- x_sep
  x
}

maestroLabel_roclet <- function() {
  roxygen2::roclet("maestroLabel")
}

#' @exportS3Method
roclet_process.roclet_maestroLabel <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tags(blocks[[1]], "maestroLabel")
  list(
    val = purrr::map(tags, ~{
      .x$val
    }),
    node = blocks[[1]]$object$topic
  )
}
