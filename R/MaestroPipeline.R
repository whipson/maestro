#' Class for an individual maestro pipeline
#' A pipeline is defined as a single R script with a schedule or input
#' @keywords internal
MaestroPipeline <- R6::R6Class(

  "MaestroPipeline",

  public = list(

    #' @description
    #' Create a new Pipeline object
    #' @param script_path path to the script
    #' @param pipe_name name of the pipeline
    #' @param frequency frequency of the pipeline (e.g., 1 day)
    #' @param start_time start time of the pipeline
    #' @param tz time zone of the pipeline
    #' @param hours specific hours of the day
    #' @param days specific days of week or month
    #' @param months specific months of year
    #' @param skip whether to skip the pipeline regardless of scheduling
    #' @param log_level log level of the pipeline
    #' @param inputs names of pipelines that this pipeline is dependent on for input
    #' @param outputs names of pipelines for which this pipeline is a dependency
    #' @param priority priority of the pipeline
    #' @param flags arbitrary pipelines flags
    #'
    #' @return MaestroPipeline object
    initialize = function(
      script_path,
      pipe_name,
      frequency = NA_character_,
      start_time = lubridate::NA_POSIXct_,
      tz = NA_character_,
      hours = NULL,
      days = NULL,
      months = NULL,
      skip = FALSE,
      log_level = "INFO",
      inputs = NULL,
      outputs = NULL,
      priority = Inf,
      flags = c()
    ) {

      # Update the private attributes
      private$script_path <- script_path
      private$pipe_name <- pipe_name
      private$skip <- skip
      private$log_level <- log_level
      private$inputs <- inputs
      private$outputs <- outputs
      private$priority <- priority
      private$flags <- flags

      if (is.null(inputs)) {

        private$tz <- tz
        private$frequency <- frequency
        private$start_time <- lubridate::with_tz(start_time, tz)
        private$hours <- hours
        private$months <- months

        # Create transformed private attributes
        # Create units and n
        withCallingHandlers({
          nunits <- purrr::map(frequency, purrr::possibly(~{
            parse_rounding_unit(.x)
          }, otherwise = list(n = NA, unit = NA)))
        }, purrr_error_indexed = function(err) {
          rlang::cnd_signal(err$parent)
        })

        # Create days_of_week and days_of_month from days
        days_of_week <- purrr::map_if(days, is.factor, as.numeric, .else = ~NA_real_) |>
          purrr::discard(is.na) |>
          purrr::list_c()
        days_of_month <- purrr::map_if(days, is.numeric, ~.x, .else = ~NA_real_) |>
          purrr::discard(is.na) |>
          purrr::list_c()

        # Update the transformed private attributes
        private$start_time_utc <- lubridate::with_tz(private$start_time, tz = "UTC")
        private$frequency_n <- purrr::map_int(nunits, ~.x$n)
        private$frequency_unit <- purrr::map_chr(nunits, ~.x$unit)
        private$days_of_week <- days_of_week %n% 1:7
        private$days_of_month <- days_of_month %n% 1:31

        # Create the run sequence
        start_time_adj <- private$start_time

        is_start_time_old <- tryCatch({
          start_time_adj < (lubridate::now() - lubridate::days(365))
        }, error = function(e) {
          TRUE
        })

        if (is_start_time_old) {
          floor_year <- lubridate::year(lubridate::now())
          start_time_adj <- lubridate::make_datetime(
            year = floor_year,
            month = lubridate::month(private$start_time),
            day = lubridate::day(private$start_time),
            hour = lubridate::hour(private$start_time),
            min = lubridate::minute(private$start_time),
            sec = lubridate::second(private$start_time),
            tz = private$tz
          )
        }

        private$run_sequence <- get_pipeline_run_sequence(
          pipeline_n = private$frequency_n,
          pipeline_unit = private$frequency_unit,
          pipeline_datetime = private$start_time,
          check_datetime = start_time_adj + lubridate::days(365 * 2),
          pipeline_hours = private$hours,
          pipeline_days_of_week = private$days_of_week,
          pipeline_days_of_month = private$days_of_month,
          pipeline_months = private$months
        )
      }
    },

    #' @description
    #' Prints the pipeline
    #' @return print
    print = function() {
      cli::cli_h3("Maestro Pipeline: {.emph {private$pipe_name}}")
      cli::cli_text("{.file {private$script_path}}")
      cli::cli_h3("Schedule")

      if (!is.null(private$inputs)) {
        cli::cli_li("Dependent on: {private$inputs}")
      } else {
        cli::cli_li("Frequency: {private$frequency}")
        cli::cli_li("Start Time: {private$start_time}")
      }

      if (!is.null(private$hours)) {
        cli::cli_li("Hours: {private$hours}")
      }

      if (!is.null(private$days_of_week)) {
        cli::cli_li("Days of week: {private$days_of_week}")
      }

      if (!is.null(private$days_of_month)) {
        cli::cli_li("Days of month: {private$days_of_month}")
      }

      if (!is.null(private$months)) {
        cli::cli_li("Months: {private$months}")
      }

      cli::cli_h3("Status")
      switch (private$status,
              `Not Run` = cli::cli_li(cli::col_magenta(private$status)),
              `Success` = cli::cli_li(cli::col_green(private$status)),
              `Warning` = cli::cli_li(cli::col_yellow(private$status)),
              `Error` = cli::cli_li(cli::col_red(private$status)),
              cli::cli_li("Unknown")
      )

      if (!is.na(private$run_time_start)) {
        cli::cli_li("On: {private$run_time_start}")
      }
    },

    #' @description
    #' Runs the pipeline
    #' @param resources named list of arguments and values to pass to the pipeline
    #' @param log_file path to the log file for logging
    #' @param quiet whether to silence console output
    #' @param log_file_max_bytes maximum bytes of the log file before trimming
    #' @param .input input values from upstream pipelines
    #' @param cli_prepend text to prepend to cli output
    #' @param log_to_console whether or not to output statements in the console (FALSE is to suppress and append to log)
    #' @param ... additional arguments (unused)
    #'
    #' @return invisible
    run = function(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e6,
      .input = NULL,
      cli_prepend = "",
      log_to_console = FALSE,
      ...
    ) {

      private$run_time_start <- lubridate::now()
      private$status <- "Success"
      pipe_name <- private$pipe_name
      script_path <- private$script_path
      log_level <- private$log_level

      if (!quiet) {
        cli::cli_progress_step("{cli_prepend}{cli::col_blue(pipe_name)}")
      }

      if (log_to_console) {
        logger_fun <- logger::appender_tee
      } else {
        logger_fun <- logger::appender_file
      }

      # Set the logger to null - we just want the text in a variable
      logger::log_threshold(level = log_level, namespace = pipe_name)
      logger::log_appender(
        appender = logger_fun(log_file, max_bytes = log_file_max_bytes),
        namespace = pipe_name
      )
      logger::log_layout(maestro_logger, namespace = pipe_name)

      # Create a context (environment) for running the pipeline
      maestro_context <- new.env()

      # Source the script
      withCallingHandlers(
        source(script_path, local = maestro_context),
        error = private$error_handler,
        warning = private$warning_handler,
        message = private$message_handler
      )

      resources <- append(resources, list(.input = .input))
      args <- formals(pipe_name, envir = maestro_context)

      results <- withCallingHandlers(
        do.call(pipe_name, args = resources[names(args)], envir = maestro_context),
        error = private$error_handler,
        warning = private$warning_handler,
        message = private$message_handler
      )

      private$artifacts <- results

      private$run_time_end <- lubridate::now()

      invisible()
    },

    #' @description
    #' Get the pipeline name
    #' @return pipeline_name
    get_pipe_name = function() {
      private$pipe_name
    },

    #' @description
    #' Get the schedule as a data.frame
    #' @return data.frame
    get_schedule = function() {
      dplyr::tibble(
        script_path = private$script_path %n% character(),
        pipe_name = private$pipe_name %n% character(),
        frequency = private$frequency %n% character(),
        start_time = private$start_time %n% lubridate::POSIXct(),
        tz = private$tz %n% character(),
        skip = private$skip %n% logical(),
        log_level = private$log_level %n% character(),
        frequency_n = private$frequency_n %n% integer(),
        frequency_unit = private$frequency_unit %n% character(),
        priority = private$priority
      )
    },

    #' @description
    #' Check whether a pipeline is scheduled to run based on orchestrator frequency and current time
    #' @param orch_unit unit of the orchestrator (e.g., day)
    #' @param orch_n number of units of the frequency
    #' @param check_datetime datetime against which to check the timeliness of the pipeline (should almost always be now)
    #' @param ... unused
    #' @return MaestroPipeline
    check_timeliness = function(orch_unit, orch_n, check_datetime = lubridate::now(), ...) {

      if (private$skip) return(FALSE)
      if (!is.null(private$inputs)) return(TRUE) # pipes with a dependency are always timely

      orch_string <- paste(orch_n, orch_unit)
      orch_frequency_seconds <- convert_to_seconds(orch_string)
      check_datetime_round <- timechange::time_round(check_datetime, unit = orch_string)

      pipeline_sequence <- private$run_sequence

      pipeline_sequence_round <- unique(timechange::time_round(pipeline_sequence, unit = orch_string))

      check_datetime_int <- as.integer(check_datetime_round)
      pipeline_seq_round_int <- as.integer(pipeline_sequence_round)
      is_scheduled_now_idx <- which(pipeline_seq_round_int %in% check_datetime_int)
      if (length(is_scheduled_now_idx) == 0) {
        is_scheduled_now <- FALSE
      } else {
        is_scheduled_now <- TRUE
      }

      if (is_scheduled_now) {
        next_run <- tryCatch({
          next_idx <- is_scheduled_now_idx + 1
          pipeline_sequence_round[[next_idx]]
        }, error = function(e) {
          NULL
        })
      } else {
        next_run <- pipeline_sequence_round[pipeline_sequence_round > check_datetime_round][[1]]
      }

      private$next_run <- next_run

      return(is_scheduled_now)
    },

    #' @description
    #' Get status of the pipeline as a data.frame
    #' @return data.frame
    get_status = function() {
      dplyr::tibble(
        pipe_name = private$pipe_name,
        script_path = private$script_path,
        invoked = private$status != "Not Run",
        success = invoked && private$status != "Error",
        pipeline_started = private$run_time_start,
        pipeline_ended = private$run_time_end,
        errors = length(private$errors$message),
        warnings = length(private$warnings),
        messages = length(private$messages),
        next_run = private$next_run
      )
    },

    #' @description
    #' Get status of the pipeline as a string
    #' @return character
    get_status_chr = function() {
      private$status
    },

    #' @description
    #' Names of pipelines that receive input from this pipeline
    #' @return character
    get_outputs = function() {
      private$outputs
    },

    #' @description
    #' Names of pipelines that input into this pipeline
    #' @return character
    get_inputs = function() {
      private$inputs
    },

    #' @description
    #' Get priority of the pipeline
    #' @return numeric
    get_priority = function() {
      private$priority
    },

    #' @description
    #' Get artifacts (return values) from the pipeline
    #' @return list
    get_artifacts = function() {
      private$artifacts
    },

    #' @description
    #' Get list of errors from the pipeline
    #' @return list
    get_errors = function() {
      private$errors
    },

    #' @description
    #' Get list of warnings from the pipeline
    #' @return list
    get_warnings = function() {
      private$warnings
    },

    #' @description
    #' Get list of messages from the pipeline
    #' @return list
    get_messages = function() {
      private$messages
    },

    #' @description
    #' Get the flags of a pipeline as a vector
    #' @return character
    get_flags = function() {
      private$flags
    },

    #' @description
    #' Update the inputs of a pipeline
    #' @param inputs character vector of inputting pipeline names
    #' @return vector
    update_inputs = function(inputs) {
      private$inputs <- inputs
    },

    #' @description
    #' Update the outputs of a pipeline
    #' @param outputs character vector of outputting pipeline names
    #' @return vector
    update_outputs = function(outputs) {
      private$outputs <- outputs
    },

    #' @description
    #' Get the run sequence of a pipeline
    #' @param outputs character vector of times
    #' @return vector
    get_run_sequence = function() {
      private$run_sequence
    }
  ),

  private = list(

    script_path = NA_character_,
    pipe_name = NA_character_,
    frequency = NA_character_,
    start_time = lubridate::NA_POSIXct_,
    tz = NA_character_,
    hours = NULL,
    months = NULL,
    skip = NA,
    log_level = NA_character_,
    inputs = NULL,
    outputs = NULL,
    priority = Inf,
    flags = c(),

    # Transformed attributes
    start_time_utc = lubridate::NA_POSIXct_,
    days_of_week = NULL,
    days_of_month = NULL,
    frequency_n = NA_integer_,
    frequency_unit = NA_character_,
    run_sequence = lubridate::NA_POSIXct_,

    # Dynamic attributes
    status = "Not Run",
    run_time_start = lubridate::NA_POSIXct_,
    run_time_end = lubridate::NA_POSIXct_,
    artifacts = NULL,
    next_run = NULL,
    errors = NULL,
    warnings = NULL,
    messages = NULL,

    error_handler = function(e) {
      private$errors <- e
      private$status <- "Error"
      logger::log_error(conditionMessage(e), namespace = private$pipe_name)
      private$run_time_end <- lubridate::now()
    },

    warning_handler = function(w) {
      warning_log <- logger::log_warn(conditionMessage(w), namespace = private$pipe_name)
      private$warnings <- c(private$warnings, w$message)
      private$status <- "Warning"
      invokeRestart("muffleWarning")
    },

    message_handler = function(m) {
      message_log <- logger::log_info(conditionMessage(m), namespace = private$pipe_name)
      private$messages <- c(private$messages, m$message)
      invokeRestart("muffleMessage")
    }
  )
)
