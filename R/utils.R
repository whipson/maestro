maestro_logger <- logger::layout_glue_generator(
  format = "[{namespace}] [{level}] [{time}]: {msg}"
)

#' Checks the validity of a schedule
#'
#' @param schedule a schedule table returned from `build_schedule`
#'
#' @return invisible or error
schedule_validity_check <- function(schedule) {

  # This function should process checks in increasing order of computational complexity!

  # A list of required columns, where the value is the check to perform
  # against the column type. Note if there are more than 1, 1st is preferred
  req_col_typed_check <- list(
    script_path = "character",
    pipe_name = "character",
    frequency = "character",
    start_time = c("POSIXct", "POSIXlt"),
    log_level = "character",
    frequency_n = c("integer", "double"),
    frequency_unit = "character"
  )

  # Check that schedule is a data.frame
  if (!"data.frame" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be a data.frame and not an object of class {class(schedule)}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # Check that schedule has at least one row
  if (nrow(schedule) == 0) {
    cli::cli_abort(
      c("Empty schedule. Schedule must have at least one row.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # Check the presence of required columns
  if (!all(names(req_col_typed_check) %in% names(schedule))) {
    missing_col_names <- names(req_col_typed_check)[which(!names(req_col_typed_check) %in% names(schedule))]
    cli::cli_abort(
      c("Schedule is missing required column{?s}: {missing_col_names}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."
      ),
      call = rlang::caller_env()
    )
  }

  # Check presence of NAs
  cols_with_missing <- purrr::map(names(req_col_typed_check), ~{
    any(is.na(schedule[.x]))
  }) |>
    purrr::list_c()

  if (any(cols_with_missing)) {
    cols_with_missing_names <- names(schedule)[cols_with_missing]
    cli::cli_abort(
      c("Schedule has column{?s} with NAs that cannot be NA: {cols_with_missing_names}",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # Perform the type check for each column
  offences <- purrr::imap(req_col_typed_check, ~{
    col <- schedule[[.y]]
    if (!any(.x %in% class(col))) {
      off <- list(
        class(col)
      ) |>
        stats::setNames(.y)
      return(off)
    }
    NULL
  }) |>
    purrr::discard(is.null)

  if (length(offences) == 1) {

    req_col_types <- req_col_typed_check[names(offences)]

    cli::cli_abort(
      c("Schedule column {.code {names(offences)}} must have type {req_col_types} and not {unlist(offences)}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  } else if (length(offences) > 1) {

    req_col_types <- req_col_typed_check[names(offences)]
    req_col_types_vec <- purrr::map_chr(req_col_types, ~.x[[1]])

    cli::cli_abort(
      c("Schedule columns {.code {names(offences)}} must have types {req_col_types_vec}, respectively; not {unlist(offences)}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  # All is good
  invisible()
}


#' Convert a duration string to number of seconds
#'
#' @param time_string string like 1 day, 2 weeks, 12 hours, etc.
#'
#' @return number of seconds
convert_to_seconds <- function(time_string) {

  stopifnot("Must be a single string" = length(time_string) == 1)

  # Extract the number and the unit from the time string
  matches <- regmatches(time_string, regexec("([0-9]+)\\s*(\\w+)", time_string))
  number <- as.numeric(matches[[1]][2])
  unit <- matches[[1]][3]

  # Define the conversion factors to seconds for each unit
  conversion_factors <- list(
    "sec" = 1,
    "secs" = 1,
    "second" = 1,
    "seconds" = 1,
    "min" = 60,
    "mins" = 60,
    "minute" = 60,
    "minutes" = 60,
    "hour" = 3600,
    "hours" = 3600,
    "day" = 86400,
    "days" = 86400,
    "week" = 604800,
    "weeks" = 604800,
    "month" = 2629800,
    "months" = 2629800,
    "quarter" = 7884000,
    "quarters" = 7884000,
    "year" = 31557600,
    "years" = 31557600
  )

  # Convert the time to seconds
  if (!is.null(conversion_factors[[unit]])) {
    seconds <- number * conversion_factors[[unit]]
  } else {
    stop("Unknown time unit")
  }

  seconds
}

valid_units <- c(
  "sec", "second", "min", "minute", "hour",
  "day", "week", "month", "quarter", "year"
)

#' Parse a time string
#'
#' @param time_string string like 1 day, 2 weeks, 12 hours, etc.
#'
#' @return nunit list
parse_rounding_unit <- function(time_string) {

  stopifnot("Must be a single string" = length(time_string) == 1)

  # Extract the number and the unit from the time string
  matches <- regmatches(time_string, regexec("([0-9]+)\\s*(\\w+)", time_string))
  number <- as.numeric(matches[[1]][2])
  unit <- matches[[1]][3]

  unit_fmt <- unit |>
    trimws() |>
    gsub("s$", "", x = _)

  if (!unit_fmt %in% valid_units) {
    stop(glue::glue("Invalid rounding unit `{time_string}`."))
  }

  return(
    list(
      n = number,
      unit = unit_fmt
    )
  )
}
