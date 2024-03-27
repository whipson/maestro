#' Run a schedule
#'
#' @param schedule a table of scheduled pipelines generated from `build_schedule()`
#' @param resources list of shared resources made available to pipelines as needed
#'
#' @return invisible
#' @export
run_schedule <- function(schedule, resources = list()) {

  # Errors if the schedule is invalid
  # We may only want to run this in the event of errors
  schedule_validity_check(schedule)

  # Function to filter which pipelines are to run (for now we run them all)

  cli::cli_alert_info("Running pipelines")

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
        run_schedule_entry(..1, ..2, ..3)
      }, quiet = TRUE
    )
  )

  invisible()
}
