maestro_logger <- logger::layout_glue_generator(
  format = "[{namespace}] [{level}] [{time}]: {msg}"
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
