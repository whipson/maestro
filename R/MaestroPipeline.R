#' Class for an individual maestro pipeline
#' A pipeline is defined as a single R script with a schedule or input
#' @keywords internal
MaestroPipeline <- R6::R6Class(

  "MaestroPipeline",

  public = list(

    #' @description
    #' Create a new Pipeline object
    #' @param pipe_name name for the entire pipeline
    #' @param pipe_data data.frame containing identifying information for each pipe of the pipeline
    #' @param adjacency_list data.frame linking inputting pipes (from) to outputting pipes (to)
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
    #'
    #' @return MaestroPipeline object
    initialize = function(
      pipe_name = NULL,
      pipe_data = data.frame(
        pipe_name = character(),
        script_path = character()
      ),
      adjacency_list = data.frame(
        from = character(),
        to = character()
      ),
      frequency = NA_character_,
      start_time = lubridate::NA_POSIXct_,
      tz = NA_character_,
      hours = NULL,
      days = NULL,
      months = NULL,
      skip = FALSE,
      log_level = "INFO",
      inputs = NULL,
      outputs = NULL
    ) {

      # Update the private attributes
      private$pipe_data <- pipe_data
      private$adjacency_list <- adjacency_list
      private$frequency <- frequency
      private$start_time <- start_time
      private$tz <- tz
      private$hours <- hours
      private$months <- months
      private$skip <- skip
      private$log_level <- log_level
      private$inputs <- inputs
      private$outputs <- outputs


      # Create the pipe name as the first pipe
      if (is.null(pipe_name) && nrow(pipe_data) > 0) {
        pipe_name <- pipe_data$pipe_name[[1]]
      }
      private$pipe_name <- pipe_name

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
    },

    #' @description
    #' Prints the pipeline
    #' @return print
    print = function() {
      cli::cli_h3("Maestro Pipeline: {.emph {private$pipe_name}}")
      cli::cli_li("with {.val {nrow(private$pipe_data)}} pipe{?s}: {.pkg {private$pipe_data$pipe_name}}")

      if (nrow(private$pipe_data) > 0) {
        cli::cli_h3("Dependency graph")
        print(maestro_dependency_graph_cli(private$adjacency_list))
      }

      cli::cli_h3("Schedule")

      cli::cli_li("Frequency: {private$frequency}")
      cli::cli_li("Start Time: {private$start_time}")

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
      switch (
        private$status,
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
    #' @param ... additional arguments (unused)
    #'
    #' @return invisible
    run = function(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e6,
      ...
    ) {

      private$run_time_start <- lubridate::now()
      private$status <- "Success"
      pipe_name <- private$pipe_name
      script_path <- private$pipe_data$script_path[[1]]
      log_level <- private$log_level

      if (!quiet) {
        cli::cli_progress_step("{cli::col_blue(pipe_name)}")
      }

      # Set the logger to null - we just want the text in a variable
      logger::log_threshold(level = log_level, namespace = pipe_name)
      logger::log_appender(
        appender = logger::appender_file(log_file, max_bytes = log_file_max_bytes),
        namespace = pipe_name
      )
      logger::log_layout(maestro_logger, namespace = pipe_name)

      # Create a context (environment) for running the pipeline
      maestro_context <- new.env()

      # Source the script
      tryCatch({
        source(script_path, local = maestro_context)
      }, error = \(e) {
        logger::log_error(conditionMessage(e), namespace = pipe_name)
        cli::cli_abort("Error sourcing {.code {pipe_name}}")
      }, warning = \(w) {
        logger::log_warn(conditionMessage(w), namespace = pipe_name)
        NULL
      })

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
        # script_path = private$script_path,
        pipe_name = private$pipe_name,
        frequency = private$frequency,
        start_time = private$start_time,
        tz = private$tz,
        skip = private$skip,
        log_level = private$log_level,
        frequency_n = private$frequency_n,
        frequency_unit = private$frequency_unit
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

      orch_string <- paste(orch_n, orch_unit)
      orch_frequency_seconds <- convert_to_seconds(orch_string)
      check_datetime_round <- timechange::time_round(check_datetime, unit = orch_string)

      pipeline_datetime_round <- timechange::time_round(private$start_time_utc, unit = orch_string)

      pipeline_sequence <- get_pipeline_run_sequence(
        pipeline_n = private$frequency_n,
        pipeline_unit = private$frequency_unit,
        pipeline_datetime = pipeline_datetime_round,
        check_datetime = check_datetime_round,
        pipeline_hours = private$hours,
        pipeline_days_of_week = private$days_of_week,
        pipeline_days_of_month = private$days_of_month,
        pipeline_months = private$months
      )

      cur_run <- utils::tail(pipeline_sequence, n = 1)
      is_scheduled_now <- check_datetime_round == cur_run

      future_sequence <- get_pipeline_run_sequence(
        pipeline_n = private$frequency_n,
        pipeline_unit = private$frequency_unit,
        pipeline_datetime = cur_run,
        check_datetime = cur_run + lubridate::years(1),
        pipeline_hours = private$hours,
        pipeline_days_of_week = private$days_of_week,
        pipeline_days_of_month = private$days_of_month,
        pipeline_months = private$months
      )

      next_run <- purrr::pluck(future_sequence, 2)

      if (is.null(next_run)) {
        pipeline_frequency_seconds <- convert_to_seconds(paste(private$frequency_n, private$frequency_unit))

        next_run <- timechange::time_round(
          timechange::time_add(
            cur_run,
            second = max(orch_frequency_seconds, pipeline_frequency_seconds)
          ),
          unit = orch_string
        )
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
        # script_path = private$script_path,
        invoked = private$status != "Not Run",
        success = invoked && private$status != "Error",
        pipeline_started = private$run_time_start,
        pipeline_ended = private$run_time_end,
        errors = length(private$errors),
        warnings = length(private$warnings),
        messages = length(private$messages),
        next_run = private$next_run
      )
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
    #' Add a dependency in a DAG pipeline
    #' @param from_name name of the pipe that is sending the input
    #' @param to_name name of the pipe that is receiving the input
    #' @param script_path path to the script containing the pipe
    #' @return invisible
    add_dag = function(from_name, to_name, script_path) {
      # stopifnot(from_name %in% self$pipe_data$pipe_name || to_name %in% self$pipe_data$pipe_name)

      if (from_name %in% private$pipe_data$pipe_name) {
        pipe_name <- to_name
      } else {
        pipe_name <- from_name
      }

      # Add it to the pipe data
      pipe_to_add <- dplyr::tibble(
        pipe_name = pipe_name,
        script_path = script_path
      )

      private$pipe_data <- private$pipe_data |>
        dplyr::add_row(pipe_to_add)

      # Add it to the adjacency list
      adj_to_add <- dplyr::tibble(
        from = from_name,
        to = to_name
      )

      private$adjacency_list <- private$adjacency_list |>
        dplyr::add_row(adj_to_add)
    }
  ),

  private = list(
    pipe_name = NULL,
    pipe_data = data.frame(
      pipe_name = character(),
      script_path = character()
    ),
    adjacency_list = data.frame(
      from = character(),
      to = character()
    ),
    frequency = NA_character_,
    start_time = lubridate::NA_POSIXct_,
    tz = NA_character_,
    hours = NULL,
    months = NULL,
    skip = NA,
    log_level = NA_character_,
    inputs = NULL,
    outputs = NULL,

    # Transformed attributes
    start_time_utc = lubridate::NA_POSIXct_,
    days_of_week = NULL,
    days_of_month = NULL,
    frequency_n = NA_integer_,
    frequency_unit = NA_character_,

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
      private$warnings <- c(private$warnings, warning_log$default$record)
      private$status <- "Warning"
      invokeRestart("muffleWarning")
    },

    message_handler = function(m) {
      message_log <- logger::log_info(conditionMessage(m), namespace = private$pipe_name)
      private$messages <- c(private$messages, message_log$default$record)
      invokeRestart("muffleMessage")
    }
  )
)
