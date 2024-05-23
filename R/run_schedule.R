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
#' @param n_show_next show the next n scheduled pipes
#' @param cores number of cpu cores to run if running in parallel. If > 1, `furrr` is used and
#' a multisession plan must be executed in the orchestrator (see details)
#' @param logging whether or not to write the logs to a file (default = `FALSE`)
#' @param log_file path to the log file (ignored if `logging == FALSE`)
#' @param log_file_max_bytes numeric specifying the maximum number of bytes allowed in the log file before purging the log (within a margin of error)
#' @param quiet print metrics to the console (default = `TRUE`)
#'
#' @return data.frame of pipeline statuses
#' @export
run_schedule <- function(
    schedule,
    orch_interval = 1,
    orch_frequency = "day",
    check_datetime = lubridate::now(tzone = "UTC"),
    resources = list(),
    run_all = FALSE,
    n_show_next = 5,
    cores = 1,
    logging = FALSE,
    log_file = "./maestro.log",
    log_file_max_bytes = 1e6,
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

      schedule <- schedule |>
        dplyr::mutate(
          is_scheduled_now = purrr::map_lgl(schedule_checks, ~.x$is_scheduled_now),
          next_run = purrr::map_vec(schedule_checks, ~.x$next_run)
        )

      pipes_to_run <- schedule |>
        dplyr::filter(is_scheduled_now)

      pipes_not_run <- schedule |>
        dplyr::filter(!is_scheduled_now)
    } else {

      schedule <- schedule |>
        dplyr::mutate(
          is_scheduled_now = TRUE,
          next_run = NA
        )

      pipes_to_run <- schedule
      pipes_not_run <- schedule |>
        dplyr::filter(FALSE)
    }

    if (logging) {
      if (!rlang::is_scalar_character(log_file)) cli::cli_abort(
        "When {.code logging == TRUE}, {.code log_file} must be a single character."
      )
      if (!file.exists(log_file)) file.create(log_file)
    } else {
      log_file <- tempfile()
    }

    if (nrow(pipes_to_run) > 0) {

      cli::cli_h3("Running pipelines {cli::col_green(cli::symbol$play)}")

      tictoc::tic(quiet = quiet)

      # Execute the schedule (possibly in parallel)
      runs <- mapper_fun(
        list(
          pipes_to_run$script_path,
          pipes_to_run$pipe_name,
          pipes_to_run$skip,
          pipes_to_run$log_level
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
              run_schedule_entry(
                ..1,
                ..2,
                resources = resources,
                log_file = log_file,
                log_level = ..4,
                log_file_max_bytes = log_file_max_bytes
              )
            }
          }, quiet = TRUE
        )
      ) |>
        purrr::set_names(pipes_to_run$script_path)

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

      # For access via last_runtime_*
      maestro_pkgenv$last_runtime_errors <- run_errors
      maestro_pkgenv$last_runtime_warnings <- run_warnings
      maestro_pkgenv$last_runtime_messages <- run_messages

      # Create status table
      status_table <- purrr::map2(schedule$script_path, schedule$pipe_name, ~{
        dplyr::tibble(
          pipe_name = .y,
          script_path = .x,
          errors = length(run_errors[[.x]]),
          warnings = length(run_warnings[[.x]]),
          skips = length(run_skips[[.x]]),
          messages = length(run_messages[[.x]]),
          success = length(run_errors[[.x]]) == 0
        )
      }) |>
        purrr::list_rbind()

      # Get the number of statuses
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
      status_table <- dplyr::tibble()
    }


    # Output for showing next pipelines schedule
    if (!run_all && n_show_next > 0 && nrow(schedule) > 0) {

      next_runs_cli <- schedule |>
        dplyr::arrange(next_run) |>
        head(n = n_show_next)

      cli::cli_h3("Next scheduled pipelines {cli::col_cyan(cli::symbol$pointer)}")
      next_run_strs <- glue::glue("{next_runs_cli$pipe_name} | {next_runs_cli$next_run}")
      cli::cli_text("Pipe name | Next scheduled run")
      cli::cli_ul(next_run_strs)
    }

    return(status_table)
  }

  if (quiet) {
    run_schedule_fun <- purrr::quietly(run_schedule_fun)
    status_table <- run_schedule_fun() |>
      purrr::pluck("result")
  } else {
    status_table <- run_schedule_fun()
  }

  return(status_table)
}
