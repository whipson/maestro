#' Run a schedule
#'
#' Given a schedule in a `maestro` project, runs the pipelines that are scheduled to execute
#' based on the current time.
#'
#' @param schedule a table of scheduled pipelines generated from `build_schedule()`
#' @inheritParams check_pipelines
#' @param resources list of shared resources made available to pipelines as needed
#' @param run_all run all pipelines regardless of the schedule (default is `FALSE`) - useful for testing
#' @param n_show_not_run show number of pipelines that did not run and when they will run next.
#'
#' @return invisible
#' @export
run_schedule <- function(
    schedule,
    orch_interval = 1,
    orch_unit = "day",
    check_datetime = lubridate::now(tzone = "UTC"),
    resources = list(),
    run_all = FALSE,
    n_show_not_run = 5
  ) {

  schedule_validity_check(schedule)

  # Select the pipelines based on the orchestrator
  if (!run_all) {
    schedule_checks <- check_pipelines(
      schedule,
      orch_interval,
      orch_unit,
      check_datetime
    )

    pipes_to_run_idx <- purrr::map_lgl(schedule_checks, ~.x$is_scheduled_now)

    pipes_to_run <- schedule[pipes_to_run_idx,]

    pipes_not_to_run_idx <- purrr::map_lgl(schedule_checks, ~!.x$is_scheduled_now)
    pipes_not_run <- schedule[pipes_not_to_run_idx,]
    pipes_not_run$next_run <- purrr::map_vec(schedule_checks[pipes_not_to_run_idx], ~.x$next_run)
  } else {
    pipes_to_run <- schedule
  }

  if (nrow(pipes_to_run) > 0) {

    cli::cli_h3("Running pipelines {cli::col_green(cli::symbol$play)}")

    # Execute the schedule
    runs <- purrr::pmap(
      list(
        pipes_to_run$script_path,
        pipes_to_run$pipe_name
      ),
      purrr::safely(
        ~{
          cli::cli_progress_step("{ ..2}")
          run_schedule_entry(..1, ..2, resources = resources)
        }, quiet = TRUE
      )
    )

    # Get the errors
    run_errors <- purrr::map(
      runs,
      ~.x$error
    ) |>
      purrr::discard(is.null)

    # Get the warnings
    run_warnings <- purrr::map(
      runs,
      ~.x$result
    ) |>
      purrr::discard(is.null)

    maestro_pkgenv$latest_runtime_errors <- run_errors
    maestro_pkgenv$latest_runtime_warnings <- run_warnings

    total <- length(runs)
    error_count <- length(run_errors)
    success_count <- total - error_count
    warning_count <- length(run_warnings)

    cli::cli_h3("Pipeline execution completed {cli::col_silver(cli::symbol$stop)}")

    cli::cli_text(
      "
      {cli::col_green(cli::symbol$tick)} {success_count} {ifelse(success_count == 1, 'success', 'successes')} |
      {cli::col_magenta('!')} {warning_count} {ifelse(warning_count == 1, 'warning', 'warnings')} |
      {cli::col_red(cli::symbol$cross)} {error_count} {ifelse(error_count == 1, 'error', 'errors')} |
      {cli::col_cyan(cli::symbol$info)} {total} total
      "
    )

    cli::cli_rule()
  } else {
    cli::cli_h3("No pipelines scheduled to run this time")
  }


  # Output for showing next pipelines schedule
  if (!run_all && n_show_not_run > 0 && nrow(pipes_not_run) > 0) {

    pipes_not_run <- pipes_not_run |>
      dplyr::arrange(next_run) |>
      head(n = n_show_not_run)

    cli::cli_h3("Next scheduled pipelines {cli::col_cyan(cli::symbol$pointer)}")
    next_run_strs <- glue::glue("{pipes_not_run$pipe_name} | {pipes_not_run$next_run}")
    cli::cli_text("Pipe name | Next scheduled run")
    cli::cli_ul(next_run_strs)
  }

  invisible()
}
