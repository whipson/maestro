maestro_logger <- logger::layout_glue_generator(
  format = "[{namespace}] [{level}] [{format(time, \"%Y-%m-%d %H:%M:%S\")}]: {msg}"
)

#' Convert a duration string to number of seconds
#'
#' @param time_string string like 1 day, 1 week, 12 hours, etc.
#' @keywords internal
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
#' @param time_string string like 1 day, daily, 1 week, 12 hours, etc.
#'
#' @keywords internal
#' @return nunit list
parse_rounding_unit <- function(time_string) {

  stopifnot("Must be a single string" = length(time_string) == 1)

  # Extract the number and the unit from the time string
  if (!grepl("^[0-9]", time_string)) {
    time_string <- switch (time_string,
      hourly = "1 hour",
      daily = "1 day",
      weekly = "1 week",
      biweekly = "2 weeks",
      monthly = "1 month",
      quarterly = "3 months",
      yearly = "1 year",
      time_string
    )
  }

  matches <- regmatches(time_string, regexec("([0-9]+)\\s*(\\w+)", time_string))
  number <- as.numeric(matches[[1]][2])
  unit <- matches[[1]][3]

  unit_fmt <- unit |>
    trimws()

  unit_fmt <- gsub("s$", "", x = unit_fmt)

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

#' Generate a sequence of run times for a pipeline
#'
#' @param check_datetime datetime against which to check the running of pipelines (default is current system time in UTC)
#' @param pipeline_n number of units for the pipeline frequency
#' @param pipeline_unit unit for the pipeline frequency
#' @param pipeline_datetime datetime of the first time the pipeline is to run
#' @param pipeline_hours vector of integers \[0-23] corresponding to hours of day for the pipeline to run
#' @param pipeline_months vector of integers \[1-12] corresponding to months of year for the pipeline to run
#' @param pipeline_days_of_week vector of integers \[1-7] corresponding to days of week for the pipeline to run (1 = Sunday)
#' @param pipeline_days_of_month vector of integers \[1-31] corresponding to days of month for the pipeline to run
#'
#' @keywords internal
#' @return vector of timestamps or dates
get_pipeline_run_sequence <- function(
    pipeline_n,
    pipeline_unit,
    pipeline_datetime,
    check_datetime,
    pipeline_hours = 0:23,
    pipeline_days_of_week = 1:7,
    pipeline_days_of_month = 1:31,
    pipeline_months = 1:12
  ) {

  check_datetime <- tryCatch({
    lubridate::as_datetime(check_datetime)
  }, error = function(e) {
    cli::cli_abort(
      "{.code check_datetime} must be a POSIXt object."
    )
  }, warning = function(w) {
    cli::cli_abort(
      "{.code check_datetime} must be a POSIXt object."
    )
  })

  pipeline_unit <- dplyr::case_match(
    pipeline_unit,
    c("minutes", "minute") ~ "min",
    c("seconds", "second") ~ "sec",
    .default = pipeline_unit
  )

  if (pipeline_datetime > check_datetime) {
    pipeline_sequence <- pipeline_datetime
  } else {
    pipeline_sequence <- seq(pipeline_datetime, check_datetime, by = paste(pipeline_n, pipeline_unit))
  }

  pipeline_sequence <- adjust_for_dst(pipeline_sequence[[1]], pipeline_sequence)

  if (!all(0:23 %in% pipeline_hours)) {
    pipeline_sequence <- pipeline_sequence[lubridate::hour(pipeline_sequence) %in% pipeline_hours]
  }

  if (!all(1:7 %in% pipeline_days_of_week)) {
    pipeline_sequence <- pipeline_sequence[lubridate::wday(pipeline_sequence, week_start = 1) %in% pipeline_days_of_week]
  }

  if (!all(1:31 %in% pipeline_days_of_month)) {
    pipeline_sequence <- pipeline_sequence[lubridate::mday(pipeline_sequence) %in% pipeline_days_of_month]
  }

  if (!all(1:12 %in% pipeline_months)) {
    pipeline_sequence <- pipeline_sequence[lubridate::month(pipeline_sequence) %in% pipeline_months]
  }

  pipeline_sequence
}

`%n%` <- function(rhs, lhs) {
  if (is.null(rhs) || length(rhs) == 0 || all(is.na(rhs))) return(lhs)
  rhs
}

#' Checks whether a DAG is valid (no loops)
#'
#' @param edges a data.frame of edges (from, to)
#'
#' @keywords internal
#' @return boolean
is_valid_dag <- function(edges) {

  # Create an adjacency list
  adj_list <- split(edges$to, edges$from)

  # Find all nodes (unique vertices)
  nodes <- unique(c(edges$from, edges$to))

  # Initialize in-degree for each node
  in_degree <- stats::setNames(rep(0, length(nodes)), nodes)

  # Calculate in-degrees
  for (to in edges$to) {
    in_degree[to] <- in_degree[to] + 1
  }

  # Topological sorting using Kahn's Algorithm
  topological_sort <- function(nodes, adj_list, in_degree) {
    sorted <- c()
    queue <- nodes[in_degree == 0]

    while (length(queue) > 0) {
      current <- queue[1]
      queue <- queue[-1]
      sorted <- c(sorted, current)

      if (!is.null(adj_list[[current]])) {
        for (neighbor in adj_list[[current]]) {
          in_degree[neighbor] <- in_degree[neighbor] - 1
          if (in_degree[neighbor] == 0) {
            queue <- c(queue, neighbor)
          }
        }
      }
    }

    length(sorted) == length(nodes)
  }

  # Check if the graph is a DAG
  is_dag <- topological_sort(nodes, adj_list, in_degree)

  is_dag
}

standardize_units <- function(unit) {
  dplyr::case_match(
    unit,
    c("second", "seconds", "sec", "secs") ~ "second",
    c("minute", "minutes", "min", "mins") ~ "minute",
    c("hour", "hours") ~ "hour",
    c("day", "days") ~ "day",
    c("week", "weeks") ~ "week",
    c("month", "months") ~ "month",
    c("quarter", "quarters") ~ "quarter",
    c("year", "years") ~ "year"
  )
}

units_lt_units <- function(u1, u2) {
  order <- c("second", "minute", "hour", "day", "week", "month", "quarter", "year")
  u1_ord <- factor(u1, levels = order, ordered = TRUE)
  u2_ord <- factor(u2, levels = order, ordered = TRUE)
  u1_ord < u2_ord
}

adjust_for_dst <- function(base_timestamp, adjustable_timestamps) {

  base_dst <- lubridate::dst(base_timestamp)

  adjustment <- ifelse(
    lubridate::dst(adjustable_timestamps) == base_dst,
    0,
    ifelse(base_dst, 1, -1)
  )

  adjustable_timestamps + lubridate::hours(adjustment)
}

validate_orch_frequency <- function(orch_frequency) {
  orch_nunits <- tryCatch({
    parse_rounding_unit(orch_frequency)
  }, error = \(e) {
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.",
        "i" = "Must be of the format like '1 day', '1 week', 'hourly', etc."
      ),
      call = NULL
    )
  })

  # Enforce minimum orch frequency of 1 year
  if (orch_nunits$unit == "year" && orch_nunits$n > 1) {
    cli::cli_abort(
      "Invalid `orch_frequency` {orch_frequency}. Minimum frequency is 1 year.",
      call = NULL
    )
  }

  # Additional parse using timechange to verify it isn't something like 500 days,
  # which isn't understood by timechange
  tryCatch({
    timechange::time_round(Sys.time(), paste(orch_nunits$n, orch_nunits$unit))
  }, error = \(e) {
    timechange_error_fmt <- gsub('\\..*', '', e$message)
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.
        {timechange_error_fmt}."
      ),
      call = NULL
    )
  })

  orch_nunits
}

eval_code_str <- function(code, vars = list(), inherit = rlang::caller_env()) {

  env <- rlang::env(inherit, !!!vars)

  exprs <- if (is.character(code)) rlang::parse_exprs(code) else {
    if (is.list(code)) code else list(code)
  }

  out <- NULL
  for (e in exprs) out <- rlang::eval_bare(e, env)
  invisible(out)
}

find_roots <- function(from, to, values = to) {

  parent_lookup <- from
  names(parent_lookup) <- to

  get_root <- function(node) {
    if (!node %in% names(parent_lookup)) {
      return(node)
    }
    Recall(parent_lookup[[node]])
  }

  purrr::map_chr(values, get_root)
}

make_id <- function(n = 6) {
  first <- sample(c(letters, LETTERS), 1)
  rest  <- sample(c(letters, LETTERS, 0:9), n - 1, replace = TRUE)

  paste0(c(first, rest), collapse = "")
}

.prev_on_cycle <- function(start,
                           current = Sys.time(),
                           amount = 1L,
                           unit = c(
                             "second", "minute", "hour",
                             "day", "week",
                             "month", "year"
                           )) {
  unit <- match.arg(unit)

  amount <- as.integer(amount)
  if (is.na(amount) || amount <= 0L) {
    stop("Internal error: `amount` must be a positive integer.")
  }

  start_is_date <- inherits(start, "Date")
  start_is_time <- inherits(start, "POSIXct")

  if (!start_is_date && !start_is_time) {
    stop("Internal error: `start` must be Date or POSIXct.")
  }

  # Coerce `current` to match `start` type
  if (start_is_date) {
    current <- as.Date(current)
    start   <- as.Date(start)
  } else {
    tz <- attr(start, "tzone")
    if (is.null(tz) || !nzchar(tz)) tz <- ""

    current <- as.POSIXct(current, tz = tz)
    start   <- as.POSIXct(start, tz = tz)
  }

  na_out <- function() {
    if (start_is_date) as.Date(NA) else as.POSIXct(NA)
  }

  if (is.na(start) || is.na(current)) return(na_out())

  if (current <= start) return(na_out())

  .days_in_month <- function(year, month) {
    y2 <- year + (month == 12L)
    m2 <- if (month == 12L) 1L else month + 1L

    first_this <- as.Date(sprintf("%04d-%02d-01", year, month))
    first_next <- as.Date(sprintf("%04d-%02d-01", y2, m2))

    as.integer(first_next - first_this)
  }

  .add_months_clamp_date <- function(date, n_months) {
    y <- as.integer(format(date, "%Y"))
    m <- as.integer(format(date, "%m"))
    d <- as.integer(format(date, "%d"))

    idx <- y * 12L + (m - 1L) + n_months
    y2 <- idx %/% 12L
    m2 <- idx %% 12L + 1L

    dim <- .days_in_month(y2, m2)
    d2 <- if (d > dim) dim else d

    as.Date(sprintf("%04d-%02d-%02d", y2, m2, d2))
  }

  .add_years_clamp_date <- function(date, n_years) {
    y <- as.integer(format(date, "%Y"))
    m <- as.integer(format(date, "%m"))
    d <- as.integer(format(date, "%d"))

    y2 <- y + n_years
    dim <- .days_in_month(y2, m)
    d2 <- if (d > dim) dim else d

    as.Date(sprintf("%04d-%02d-%02d", y2, m, d2))
  }

  .add_months_clamp_time <- function(ts, n_months) {
    tz <- attr(ts, "tzone")
    if (is.null(tz) || !nzchar(tz)) tz <- ""

    lt <- as.POSIXlt(ts, tz = tz)

    y <- lt$year + 1900L
    m <- lt$mon + 1L
    d <- lt$mday

    idx <- y * 12L + (m - 1L) + n_months
    y2 <- idx %/% 12L
    m2 <- idx %% 12L + 1L

    dim <- .days_in_month(y2, m2)
    d2 <- if (d > dim) dim else d

    ISOdatetime(y2, m2, d2, lt$hour, lt$min, lt$sec, tz = tz)
  }

  .add_years_clamp_time <- function(ts, n_years) {
    tz <- attr(ts, "tzone")
    if (is.null(tz) || !nzchar(tz)) tz <- ""

    lt <- as.POSIXlt(ts, tz = tz)

    y2 <- (lt$year + 1900L) + n_years
    m  <- lt$mon + 1L
    d  <- lt$mday

    dim <- .days_in_month(y2, m)
    d2 <- if (d > dim) dim else d

    ISOdatetime(y2, m, d2, lt$hour, lt$min, lt$sec, tz = tz)
  }

  if (start_is_date) {
    if (unit %in% c("second", "minute", "hour")) {
      stop("Internal error: sub-day units are not supported for Date inputs.")
    }

    if (unit %in% c("day", "week")) {
      step_days <- if (unit == "week") amount * 7L else amount
      delta_days <- as.integer(current - start)
      k <- (delta_days - 1L) %/% step_days
      if (k < 0L) return(na_out())
      return(start + k * step_days)
    }

    sy <- as.integer(format(start, "%Y"))
    sm <- as.integer(format(start, "%m"))
    cy <- as.integer(format(current, "%Y"))
    cm <- as.integer(format(current, "%m"))

    if (unit == "month") {
      start_idx <- sy * 12L + (sm - 1L)
      curr_idx  <- cy * 12L + (cm - 1L)

      delta_months <- curr_idx - start_idx
      n <- (delta_months %/% amount) * amount

      cand <- .add_months_clamp_date(start, n)

      if (cand >= current) {
        n2 <- n - amount
        if (n2 < 0L) return(na_out())
        cand <- .add_months_clamp_date(start, n2)
      }

      return(cand)
    }

    delta_years <- cy - sy
    n <- (delta_years %/% amount) * amount

    cand <- .add_years_clamp_date(start, n)

    if (cand >= current) {
      n2 <- n - amount
      if (n2 < 0L) return(na_out())
      cand <- .add_years_clamp_date(start, n2)
    }

    return(cand)
  }

  # POSIXct branch
  if (unit %in% c("second", "minute", "hour", "day", "week")) {
    step_secs <- switch(
      unit,
      second = amount,
      minute = amount * 60,
      hour   = amount * 3600,
      day    = amount * 86400,
      week   = amount * 7 * 86400
    )

    delta_secs <- as.numeric(difftime(current, start, units = "secs"))

    # epsilon avoids returning `current` if it lies exactly on the cycle
    k <- floor((delta_secs - 1e-9) / step_secs)
    if (is.na(k) || k < 0) return(na_out())

    return(start + k * step_secs)
  }

  sy <- as.integer(format(start, "%Y"))
  sm <- as.integer(format(start, "%m"))
  cy <- as.integer(format(current, "%Y"))
  cm <- as.integer(format(current, "%m"))

  if (unit == "month") {
    start_idx <- sy * 12L + (sm - 1L)
    curr_idx  <- cy * 12L + (cm - 1L)

    delta_months <- curr_idx - start_idx
    n <- (delta_months %/% amount) * amount

    cand <- .add_months_clamp_time(start, n)

    if (cand >= current) {
      n2 <- n - amount
      if (n2 < 0L) return(na_out())
      cand <- .add_months_clamp_time(start, n2)
    }

    return(cand)
  }

  delta_years <- cy - sy
  n <- (delta_years %/% amount) * amount

  cand <- .add_years_clamp_time(start, n)

  if (cand >= current) {
    n2 <- n - amount
    if (n2 < 0L) return(na_out())
    cand <- .add_years_clamp_time(start, n2)
  }

  cand
}