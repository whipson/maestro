#' Run a schedule
#'
#' @param schedule a table of scheduled pipelines generated from `build_schedule()`
#' @inheritParams select_pipelines
#' @param resources list of shared resources made available to pipelines as needed
#'
#' @return invisible
#' @export
run_schedule <- function(
    schedule,
    orch_interval = 1,
    orch_unit = "day",
    check_datetime = Sys.time(),
    resources = list(),
    run_all = FALSE
  ) {

  schedule_validity_check(schedule)

  # Select the pipelines based on the orchestrator
  if (!run_all) {
    schedule <- select_pipelines(
      schedule,
      orch_interval,
      orch_unit,
      check_datetime
    )
  }

  cli::cli_h3("Running pipelines {cli::col_green(cli::symbol$play)}")

  warning_count <- 0
  warnings <- list()

  # Execute the schedule
  runs <- purrr::pmap(
    list(
      schedule$script_path,
      schedule$pipe_name,
      schedule$is_func
    ),
    purrr::safely(
      ~{

        cli::cli_progress_step("{ ..2}")

        # Catch warnings
        tryCatch({
          run_schedule_entry(..1, ..2, ..3, resources = resources)
        }, warning = \(w) {
          warning_count <<- warning_count + 1
          warnings <<- append(warnings, w$message)
        })
      }, quiet = TRUE
    )
  )

  if (length(runs) == 0) {
    cli::cli_inform("No pipelines scheduled to run")
    return(invisible())
  }

  # Get the errors
  run_errors <- purrr::map(
    runs,
    ~.x$error
  ) |>
    purrr::discard(is.null)

  baton_pkgenv$latest_runtime_errors <- run_errors

  total <- length(runs)
  error_count <- length(run_errors)
  success_count <- total - error_count

  cli::cli_h3("Pipeline execution completed {cli::col_silver(cli::symbol$stop)}")

  cli::cli_text("
    {cli::col_green(cli::symbol$tick)} {success_count} {ifelse(success_count == 1, 'success', 'successes')} |
    {cli::col_magenta('!')} {warning_count} {ifelse(warning_count == 1, 'warning', 'warnings')} |
    {cli::col_red(cli::symbol$cross)} {error_count} {ifelse(error_count == 1, 'error', 'errors')} |
    {cli::col_cyan(cli::symbol$info)} {total} total
    "
  )

  invisible()
}
