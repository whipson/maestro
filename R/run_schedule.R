#' Run a schedule
#'
#' Given a schedule in a `maestro` project, runs the pipelines that are scheduled to execute
#' based on the current time.
#'
#' @md
#' @details
#'
#' ## Pipeline schedule logic
#'
#' The function `run_schedule()` examines each pipeline in the schedule table and determines
#' whether it is scheduled to run at the current time using some simple time arithmetic. We assume
#' `run_schedule(schedule, check_datetime = Sys.time())`, but this need not be the case.
#'
#' ## Pipelines with arguments (resources)
#'
#' If a pipeline takes an argument that doesn't include a default value, these can be supplied
#' in the orchestrator via `run_schedule(resources = list(arg1 = val))`. The name of the argument
#' used by the pipeline must match the name of the argument in the list. Currently, each named
#' resource must refer to a single object. In other words, you can't have two pipes using
#' the same argument but requiring different values.
#'
#' ## Running in parallel
#' Pipelines can be run in parallel using the `cores` argument. First, you must run `future::plan(future::multisession)`
#' in the orchestrator. Then, supply the desired number of cores to the `cores` argument. Note that
#' console output appears different in multicore mode.
#'
#' @param schedule a table of scheduled pipelines generated from `build_schedule()`
#' @inheritParams check_pipelines
#' @param resources named list of shared resources made available to pipelines as needed
#' @param run_all run all pipelines regardless of the schedule (default is `FALSE`) - useful for testing.
#' Does not apply to pipes with a `maestroSkip` tag.
#' @param n_show_not_run show number of pipelines that did not run and when they will run next.
#' @param cores number of cpu cores to run if running in parallel. If > 1, `furrr` is used and
#' a multisession plan must be executed in the orchestrator (see details)
#' @param quiet print metrics to the console (default = `TRUE`)
#'
#' @return invisible
#' @export
run_schedule <- function(
    schedule,
    orch_interval = 1,
    orch_frequency = "day",
    check_datetime = lubridate::now(tzone = "UTC"),
    resources = list(),
    run_all = FALSE,
    n_show_not_run = 5,
    cores = 1,
    quiet = FALSE
  ) {

  # Check validity of the schedule
  schedule_validity_check(schedule)

  # Ensure that elements in resources are named
  if (length(resources) > 0) {
    resources_length <- length(resources)
    n_named <- sum(names(resources) != "")
    if (resources_length > n_named) {
      cli::cli_abort(
        "All elements in `resources` must be named."
      )
    }

    n_uniq_names <- length(unique(names(resources)))
    if (resources_length > n_uniq_names) {
      cli::cli_abort(
        "All elements in `resources` must have unique names."
      )
    }
  }

  # Parallelization
  mapper_fun <- function(...) {
    purrr::pmap(...)
  }
  if (!is.null(cores)) {
    if (cores < 1 || (cores %% 1) != 0) cli::cli_abort("`cores` must be a positive integer")
    if (cores > 1) {
      tryCatch({
        requireNamespace("furrr")
        mapper_fun <- function(...) {
          furrr::future_pmap(..., .options = furrr::furrr_options(stdout = FALSE))
        }
      }, error = \(e) {
        cli::cli_warn("{.pkg furrr} is required for running on multiple cores.")
      })
    }
  }

  run_schedule_fun <- function() {

    # Select the pipelines based on the orchestrator
    if (!run_all) {
      schedule_checks <- check_pipelines(
        schedule,
        orch_interval,
        orch_frequency,
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

      tictoc::tic(quiet = quiet)

      # Execute the schedule
      runs <- mapper_fun(
        list(
          pipes_to_run$script_path,
          pipes_to_run$pipe_name,
          pipes_to_run$skip
        ),
        purrr::safely(
          ~{
            if (..3) {
              cli::cli_alert("{cli::col_silver(..1)} { ..2}")
              return(
                list(
                  warnings = NULL,
                  messages = NULL,
                  skip = TRUE
                )
              )
            } else {
              cli::cli_progress_step("{cli::col_silver(..1)} {.pkg { ..2}}")
              run_schedule_entry(..1, ..2, resources = resources)
            }
          }, quiet = TRUE
        )
      ) |>
        purrr::set_names(pipes_to_run$pipe_name)

      elapsed <- tictoc::toc(quiet = TRUE)

      # Get the errors
      run_errors <- purrr::map(
        runs,
        ~.x$error
      ) |>
        purrr::discard(is.null)

      # Get the warnings
      run_warnings <- purrr::map(
        runs,
        ~.x$result$warnings
      ) |>
        purrr::discard(is.null)

      # Get the skips
      run_skips <- purrr::map(
        runs,
        ~.x$result$skip
      ) |>
        purrr::discard(is.null)

      # Get the messages
      run_messages <- purrr::map(
        runs,
        ~.x$result$messages
      ) |>
        purrr::discard(is.null)

      maestro_pkgenv$last_runtime_errors <- run_errors
      maestro_pkgenv$last_runtime_warnings <- run_warnings
      maestro_pkgenv$last_runtime_messages <- run_messages

      total <- length(runs)
      error_count <- length(run_errors)
      skip_count <- length(run_skips)
      success_count <- total - error_count - skip_count
      warning_count <- length(run_warnings)

      cli::cli_h3("Pipeline execution completed {cli::col_silver(cli::symbol$stop)} | {elapsed$callback_msg}")

      cli::cli_text(
        "
      {cli::col_green(cli::symbol$tick)} {success_count} {ifelse(success_count == 1, 'success', 'successes')} |
      {cli::col_black(cli::symbol$arrow_right)} {skip_count} skipped |
      {cli::col_magenta('!')} {warning_count} {ifelse(warning_count == 1, 'warning', 'warnings')} |
      {cli::col_red(cli::symbol$cross)} {error_count} {ifelse(error_count == 1, 'error', 'errors')} |
      {cli::col_cyan(cli::symbol$square_small_filled)} {total} total
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

  if (quiet) {
    run_schedule_fun <- purrr::quietly(run_schedule_fun)
  }

  run_schedule_fun()
}
