#' Get time slot usage of a schedule
#'
#' Get the number of pipelines scheduled to run for each time slot at a particular
#' slot interval. Time slots are times that the orchestrator runs and the slot interval
#' determines the level of granularity to consider.
#'
#' This function is particularly useful when you have multiple pipelines in a project
#' and you want to see what recurring time intervals may be available or underused
#' for new pipelines.
#'
#' Note that this function is intended for use in an interactive session while developing
#' a maestro project. It is not intended for use in the orchestrator.
#'
#' As an example, consider we have four pipelines running at various frequencies
#' and the orchestrator running every hour. Then let's say there's to be a new
#' pipeline that runs every day. One might ask 'what hour should I schedule this new
#' pipeline to run on?'. By using `get_slot_usage(schedule, orch_frequency = '1 hour', slot_interval = 'hour')`
#' on the existing schedule, you could identify for each hour how many pipelines
#' are already scheduled to run and choose the ones with the lowest usage.
#'
#' @inheritParams run_schedule
#' @param slot_interval a time unit indicating the interval of time to consider between slots (e.g., 'hour', 'day')
#'
#' @returns data.frame
#' @export
#'
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   get_slot_usage(
#'     schedule,
#'     orch_frequency = "1 hour",
#'     slot_interval = "hour"
#'   )
#' }
get_slot_usage <- function(schedule, orch_frequency, slot_interval = "hour") {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c("Schedule must be an object of {.cls MaestroSchedule} and not an object of class {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."),
      call = rlang::caller_env()
    )
  }

  if (length(schedule$PipelineList$MaestroPipelines) == 0) {
    cli::cli_inform("No pipelines in schedule.")
    return(invisible())
  }

  # Get the orchestrator nunits
  orch_nunits <- validate_orch_frequency(orch_frequency)

  window_std <- standardize_units(slot_interval)

  if (!window_std %in% valid_units) {
    cli::cli_abort(
      "`slot_interval` must be a valid time unit such as 'hour', 'day', 'week', etc."
    )
  }

  run_sequences <- schedule$PipelineList$get_run_sequences()

  run_sequences_all <- run_sequences |>
    purrr::imap(
      ~dplyr::tibble(
        pipe_name = .y,
        slot = .x
      )
    ) |>
    purrr::list_rbind()

  window_fmt <- switch (window_std,
    second = "%S",
    minute = "%M",
    hour = "%H:%M",
    day = "%d",
    week = "%a",
    month = "%b",
    quarter = "%b",
    year = "%Y"
  )

  run_sequences_all |>
    dplyr::filter(!is.na(slot)) |>
    dplyr::mutate(
      slot = format(slot, window_fmt)
    ) |>
    dplyr::distinct(pipe_name, slot) |>
    dplyr::summarise(
      n_runs = dplyr::n(),
      pipe_names = paste(pipe_name, collapse = ", "),
      .by = slot
    ) |>
    dplyr::arrange(slot)
}
