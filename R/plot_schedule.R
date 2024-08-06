#' Plot pipeline runs from a schedule
#'
#' Generates a plot of expected pipeline runs based on
#' a schedule and an orchestrator frequency.
#'
#' @inheritParams run_schedule
#' @param start_datetime date or timestamp for the start of the schedule
#' @param end_datetime date or timestamp for the end of the schedule
#' @param interactive whether to generate an interactive plot using `plotly` (default is `TRUE`)
#' @param fill named or hex color for the tiles
#'
#' @return interactive (via plotly) or static plot (via ggplot)
#' @export
#'
#' @examples
#' pipeline_dir <- tempdir()
#' create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE, overwrite = TRUE)
#' schedule <- build_schedule(pipeline_dir = pipeline_dir)
#' plot_schedule(schedule, orch_frequency = "1 hour", interactive = FALSE)
plot_schedule <- function(
    schedule,
    orch_frequency = "1 hour",
    start_datetime = lubridate::now(tzone = "UTC"),
    end_datetime = start_datetime + lubridate::days(7),
    fill = "#9012C790",
    interactive = TRUE
  ) {

  rlang::check_installed("ggplot2")
  if (interactive) {
    rlang::check_installed("plotly")
  }

  if (!any(class(start_datetime) %in% c("Date", "POSIXct", "POSIXlt"))) {
    cli::cli_abort(
      "{.code start_datetime} must be a single Date or POSIXct/POSIXlt value."
    )
  }

  if (!any(class(end_datetime) %in% c("Date", "POSIXct", "POSIXlt"))) {
    cli::cli_abort(
      "{.code end_datetime} must be a single Date or POSIXct/POSIXlt value."
    )
  }

  if (end_datetime <= start_datetime) {
    cli::cli_abort(
      "{.code end_datetime} must be later than {.code start_datetime}."
    )
  }

  # Check validity of the schedule
  schedule_validity_check(schedule)

  # Get the orchestrator nunits
  orch_nunits <- tryCatch({
    parse_rounding_unit(orch_frequency)
  }, error = \(e) {
    cli::cli_abort(
      c(
        "Invalid `orch_frequency` {orch_frequency}.",
        "i" = "Must be of the format like '1 day', '2 weeks', etc."
      ),
      call = NULL
    )
  })

  # Additional parse using timechange to verify it isn't something like 500 days,
  # which isn't understood by timechange
  tryCatch({
    timechange::time_round(Sys.time(), orch_frequency)
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


  sch_secs <- purrr::map_int(
    schedule$frequency,
    purrr::possibly(convert_to_seconds, otherwise = NA, quiet = TRUE)
  )

  max_freq <- schedule$frequency[[which.max(sch_secs)]]

  pipeline_sequences <- purrr::pmap(
    list(schedule$frequency_n, schedule$frequency_unit, schedule$start_time, schedule$script_path, schedule$pipe_name, schedule$frequency),
    ~{
      pipeline_sequence <- get_pipeline_run_sequence(
        ..1, ..2, ..3,
        check_datetime = start_datetime + convert_to_seconds(max_freq)
      )

      pipeline_sequence <- pipeline_sequence[
        pipeline_sequence >= start_datetime & pipeline_sequence <= end_datetime
      ]

      dplyr::tibble(
        script_path = ..4,
        pipe_name = ..5,
        frequency = ..6,
        run_time = pipeline_sequence
      )
    }
  ) |>
    purrr::list_rbind()

  p <- pipeline_sequences |>
    dplyr::mutate(
      run_date = as.Date(run_time),
      run_time_15min = lubridate::round_date(run_time, "15 minutes")
    ) |>
    dplyr::summarise(
      n_runs = dplyr::n(),
      pipe_name = paste(pipe_name, "~", frequency),
      .by = c(pipe_name, frequency, run_date, run_time_15min)
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(run_time_15min, n_runs, text = format(run_time_15min, "%Y-%m-%d %H:%M:%S %Z"))
    ) +
    ggplot2::geom_tile(color = "black", fill = fill) +
    ggplot2::labs(
      x = NULL,
      y = NULL,
      title = "Maestro Schedule"
    ) +
    ggplot2::facet_wrap(~pipe_name, ncol = 1) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank()
    )

  if (interactive) {

    p <- plotly::ggplotly(p, tooltip = "text") |>
      plotly::config(displayModeBar = FALSE)
  }

  p
}
