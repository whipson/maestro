#' Round time formatted
#'
#' @param check_datetime POSIXct object
#' @param unit_value unit to round to
#'
#' @return character
round_time <- function(check_datetime, unit_value) {
  format(
    as.POSIXct(lubridate::round_date(check_datetime, unit = unit_value), format = "%H:%M"),
    "%H:%M:%S"
  )
}

#' Checks the validity of a schedule
#'
#' @param schedule_table a schedule table returned from `build_schedule`
#'
#' @return invisible or error
schedule_validity_check <- function(schedule) {

  # A list of required columns, where the value is the check to perform
  # against the column type. Note if there are more than 1, 1st is preferred
  req_col_typed_check <- list(
    script_path = "character",
    pipe_name = "character",
    is_func = "logical",
    frequency = "character",
    interval = c("integer", "numeric"),
    start_time = c("POSIXct", "POSIXlt")
  )

  # Check that schedule is a data.frame
  if (!"data.frame" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be a data.frame and not an object of class {class(schedule)}.",
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
