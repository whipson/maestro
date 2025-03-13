#' Parse and validate tags then create and populate MaestroPipelineList
#'
#' @param script_path path to script
#'
#' @keywords internal
#'
#' @return MaestroPipelineList R6 class
build_schedule_entry <- function(script_path) {

  # Current list of maestro tags and their equivalent table names
  maestro_tag_names <- list(
    frequency = "maestroFrequency",
    start_time = "maestroStartTime",
    tz = "maestroTz",
    skip = "maestroSkip",
    log_level = "maestroLogLevel",
    hours = "maestroHours",
    days = "maestroDays",
    months = "maestroMonths",
    inputs = "maestroInputs",
    outputs = "maestroOutputs",
    maestro = "maestro"
  )

  # Initial Validation ------------------------------------------------------

  # Get all the roxygen tags - this actually executes the script, which is fine
  # if it's functions but can be problematic if it includes other code that
  # evaluates immediately
  tag_list <- tryCatch({
    parse_env <- new.env()
    parse <- function() roxygen2::parse_file(script_path)
    environment(parse) <- parse_env
    parse()
  }, error = \(e) {
    cli::cli_abort(
      c("Could not build schedule entry with error: {e$message}",
        "i" = "Pipeline scripts should not typically include code that's run
        outside of a function. Be sure to wrap code in a function block."),
      call = NULL
    )
  }, warning = \(w) {
    cli::cli_abort(w$message, call = NULL)
  }) |>
    suppressMessages()

  # Get specifically the tags used by maestro
  withCallingHandlers({
    maestro_tag_vals <- purrr::map(tag_list, ~{
      tag <- .x
      val <- purrr::map(
        maestro_tag_names,
        ~{
          val <- roxygen2::block_get_tag_value(tag, .x)
          if (is.null(val)) {
            val <- NA
          }
          val
        }
      )
      val
    })
  },
  purrr_error_indexed = function(err) {
    rlang::cnd_signal(err$parent)
  })

  if (length(maestro_tag_vals) == 0) {
    cli::cli_abort(
      c("No {.pkg maestro} tags present in {basename(script_path)}.",
        "i" = "A valid pipeline must have at least one function with one or
        more {.pkg maestro} tags: e.g., `#' @maestroFrequency 1 day`."),
      call = NULL
    )
  }

  # Checks on pipelines with maestroInput
  withCallingHandlers({
    purrr::walk2(tag_list, maestro_tag_vals, ~{
      if (!all(is.na(.y$inputs))) {

        pipe_name <- .x$object$topic
        inputs <- roxygen2::block_get_tag_value(.x, "maestroInputs")
        if (pipe_name %in% inputs) {
          cli::cli_abort(
            c("`@maestroInput` cannot contain self-references. Pipeline {.pkg pipe_name} in {basename(script_path)}
              contains an input with the same name."),
            call = NULL
          )
        }

        params <- roxygen2::block_get_tag_value(.x, ".formals")
        if (!".input" %in% params) {
          cli::cli_abort(
            c("If specifying `@maestroInputs` the pipeline must have a parameter named `.input`",
              "i" = "Example: {.code pipeline <- function(.input) ...}"),
            call = NULL
          )
        }
      }
    })
  }, purrr_error_indexed = function(err) {
    rlang::cnd_signal(err$parent)
  })

  # Checks on pipelines with maestroOutput
  withCallingHandlers({
    purrr::walk2(tag_list, maestro_tag_vals, ~{
      if (!all(is.na(.y$outputs))) {

        pipe_name <- .x$object$topic
        outputs <- roxygen2::block_get_tag_value(.x, "maestroOutputs")
        if (pipe_name %in% outputs) {
          cli::cli_abort(
            c("`@maestroOutput` cannot contain self-references. Pipeline {.pkg pipe_name} in {basename(script_path)}
              contains an output with the same name."),
            call = NULL
          )
        }
      }
    })
  }, purrr_error_indexed = function(err) {
    rlang::cnd_signal(err$parent)
  })

  # Get pipe names from the function name and check
  withCallingHandlers({
    pipe_names <- purrr::imap(tag_list, ~{

      obj_class <- class(.x$object)

      # Check that it is a function
      if (!"function" %in% obj_class) {
        cli::cli_abort(
          c("{basename(script_path)} line {(.x$line)} has tags but no function. Be sure place
          tags above the function you want to schedule."),
          call = NULL
        )
      }

      # Return the name
      .x$object$topic
    })
  }, purrr_error_indexed = function(err) {
    rlang::cnd_signal(err$parent)
  })


  # Create MaestroPipelineList ----------------------------------------------

  maestro_pipeline_list <- MaestroPipelineList$new()

  withCallingHandlers({
    purrr::walk2(pipe_names, maestro_tag_vals, ~{

      # Validate hours
      if (!all(is.na(maestro_tag_vals[[1]]$hours)) && !maestro_tag_vals[[1]]$frequency %in% c("hourly", "1 hour")) {
        cli::cli_abort(
          c("If specifying `@maestroHours` the pipeline must have a `@maestroFrequency` of 'hourly'.",
            "i" = "Issue is with pipeline named {.x}."),
          call = NULL
        )
      }

      # Validate days
      if (!all(is.na(maestro_tag_vals[[1]]$days)) &&
          !maestro_tag_vals[[1]]$frequency %in% c("daily", "hourly", "1 day", "1 hour")) {
        cli::cli_abort(
          c("If specifying `@maestroDays` the pipeline must have a `@maestroFrequency` of 'daily' or 'hourly'.",
            "i" = "Issue is with pipeline named {.x}."),
          call = NULL
        )
      }

      # Validate months
      if (!all(is.na(maestro_tag_vals[[1]]$months)) && !maestro_tag_vals[[1]]$frequency %in%
          c("monthly", "biweekly", "weekly", "daily", "hourly", "1 month", "1 week", "1 day", "1 hour")) {
        cli::cli_abort(
          c("If specifying `@maestroMonths` the pipeline must have a `@maestroFrequency` of
          'monthly', 'biweekly', 'weekly', 'daily', or 'hourly'.",
            "i" = "Issue is with pipeline named {.x}."),
          call = NULL
        )
      }

      tz <- .y$tz %n% "UTC"

      # Create the new pipeline
      pipeline <- MaestroPipeline$new(
        script_path = script_path,
        pipe_name = .x,
        frequency = .y$frequency %n% "daily",
        start_time = as.POSIXct(.y$start_time, tz = tz) %n% as.POSIXct("2024-01-01 00:00:00", tz = tz),
        tz = tz,
        skip = .y$skip %n% FALSE,
        log_level = .y$log_level %n% "INFO",
        hours = .y$hours %n% 0:23,
        days = .y$days %n% NULL,
        months = .y$months %n% 1:12,
        inputs = .y$inputs %n% NULL,
        outputs = .y$outputs %n% NULL
      )

      # Append to the list of pipelines
      maestro_pipeline_list$add_pipelines(pipeline)
    })
  }, purrr_error_indexed = function(err) {
    rlang::cnd_signal(err$parent)
  })

  maestro_pipeline_list
}
