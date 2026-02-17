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
    #' @param run_if string representing an R expression that can be evaluated and returns TRUE or FALSE; or NULL
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
      flags = c(),
      run_if = NULL
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
      private$run_if <- if (!is.null(run_if) && trimws(run_if) == "") NULL else run_if

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
        private$frequency_n <- purrr::map_int(nunits, "n")
        private$frequency_unit <- purrr::map_chr(nunits, "unit")
        private$days_of_week <- days_of_week %n% 1:7
        private$days_of_month <- days_of_month %n% 1:31

        start_time_adj <- .prev_on_cycle(
          private$start_time,
          current = lubridate::now(), 
          amount = private$frequency_n,
          unit = private$frequency_unit
        )

        if (is.na(start_time_adj)) {
          start_time_adj <- private$start_time
        }

        check_dt_days_out <- switch(
          private$frequency_unit,
          second = 3,
          minute = 7,
          hour = 60,
          day = 120,
          week = 240,
          month = 365 * 2,
          quarter = 365 * 4,
          year = 365 * 10
        )

        private$run_sequence <- get_pipeline_run_sequence(
          pipeline_n = private$frequency_n,
          pipeline_unit = private$frequency_unit,
          pipeline_datetime = private$start_time,
          check_datetime = start_time_adj + lubridate::days(check_dt_days_out),
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
    #' @param depth number of inputting pipelines above the current
    #' @param log_to_console whether or not to output statements in the console (FALSE is to suppress and append to log)
    #' @param run_id unique id for the run
    #' @param input_run_id unique id of the run that inputted into the current run (NA if there is no input)
    #' @param lineage character vector of upstream pipeline names ordered from first to latest (or empty if no upstream pipes)
    #' @param ... additional arguments (unused)
    #'
    #' @return invisible
    run = function(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e6,
      .input = NULL,
      depth = 0,
      log_to_console = FALSE,
      run_id = NA_character_,
      input_run_id = NA_character_,
      lineage = c(),
      ...
    ) {

      internal_run_id <- make_id()

      pipe_name <- private$pipe_name
      script_path <- private$script_path
      log_level <- private$log_level
      lineage <- paste0(c(lineage, pipe_name), collapse = "->")

      private$insert_run_time_attributes(
        internal_run_id,
        list(
          invoked = FALSE,
          success = NA,
          errors = 0L,
          warnings = 0L,
          messages = 0L
        )
      )

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

      do_run <- TRUE
      if (!is.null(private$run_if)) {

        if (!quiet) {
          prepend <- ""
          if (depth != 0) {
            prepend <- cli::format_inline(rep("  ", times = depth), "|-")
          }
          cli::cli_progress_step("{prepend}{cli::col_blue(pipe_name)} (?)")
        }

        cond <- withCallingHandlers(
          eval_code_str(
            private$run_if,
            vars = resources,
            inherit = maestro_context
          ),
          error = private$cond_error_handler(internal_run_id = internal_run_id),
          warning = private$cond_warning_handler(internal_run_id = internal_run_id),
          message = private$cond_message_handler(internal_run_id = internal_run_id)
        )

        if (!rlang::is_scalar_logical(cond)) {
          withCallingHandlers(
            stop(glue::glue("`{private$run_if}` did not return a single boolean."), call. = FALSE),
            error = private$cond_error_handler(internal_run_id = internal_run_id)
          )
        }

        do_run <- cond
      }

      if (!do_run) return(invisible())
      
      private$status <- "Success"

      run_time_start <- lubridate::now()
      private$run_time_start <- run_time_start

      if (!quiet) {
        prepend <- ""
        if (depth != 0) {
          prepend <- cli::format_inline(rep("  ", times = depth), "|-")
        }
        cli::cli_progress_step("{prepend}{cli::col_blue(pipe_name)}")
      }

      private$insert_run_time_attributes(
        internal_run_id, 
        list(
          run_id = run_id,
          invoked = TRUE,
          pipeline_started = run_time_start,
          input_run_id = input_run_id,
          lineage = lineage
        )
      )

      results <- withCallingHandlers(
        do.call(pipe_name, args = resources[names(args)], envir = maestro_context),
        error = private$error_handler(internal_run_id = internal_run_id),
        warning = private$warning_handler(internal_run_id = internal_run_id),
        message = private$message_handler(internal_run_id = internal_run_id)
      )

      private$returns <- results

      run_time_end <- lubridate::now()
      private$run_time_end <- run_time_end

      private$run_time_artifacts[[internal_run_id]] <- results
      private$insert_run_time_attributes(
        internal_run_id, 
        list(
          success = TRUE,
          pipeline_ended = run_time_end
        )
      )

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
        script_path = private$script_path %n% NA_character_,
        pipe_name = private$pipe_name %n% NA_character_,
        frequency = private$frequency %n% NA_character_,
        start_time = private$start_time %n% lubridate::NA_POSIXct_,
        tz = private$tz %n% NA_character_,
        skip = private$skip %n% NA,
        log_level = private$log_level %n% NA_character_,
        frequency_n = private$frequency_n %n% NA_integer_,
        frequency_unit = private$frequency_unit %n% NA_character_,
        priority = private$priority %n% NA_integer_ 
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

      if (inherits(check_datetime_round, "Date")) {
        pipeline_sequence <- lubridate::as_date(pipeline_sequence)
      }

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
        private$run_time_attributes,
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
    #' Get immediate return values from the pipeline for downstream pipelines
    #' @return list
    get_returns = function() {
      private$returns
    },

    #' @description
    #' Get artifacts (return values) from the pipeline
    #' @return list
    get_artifacts = function() {
      if (length(private$run_time_artifacts) == 1) return(private$run_time_artifacts[[1]])
      private$run_time_artifacts
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
    #' Resets run time attributes
    #' @return invisible
    reset_run_time_attributes = function() {
      private$run_time_attributes <- dplyr::tibble(
        internal_run_id = NA_character_,
        invoked = FALSE,
        success = NA,
        pipeline_started = lubridate::NA_POSIXct_,
        pipeline_ended = lubridate::NA_POSIXct_,
        errors = 0L,
        warnings = 0L,
        messages = 0L,
        run_id = NA_character_,
        input_run_id = NA_character_,
        lineage = NA_character_
      )
      private$status <- "Not Run"
      private$errors <- NULL
      private$warnings <- NULL
      private$messages <- NULL
      private$returns <- NULL
      private$run_time_start <- lubridate::NA_POSIXct_
      private$run_time_end <- lubridate::NA_POSIXct_
    },

    #' @description
    #' Get the run sequence of a pipeline
    #' @param n optional sequence limit
    #' @param min_datetime optional minimum datetime
    #' @param max_datetime optional maximum datetime
    #' @return vector
    get_run_sequence = function(n = NULL, min_datetime = NULL, max_datetime = NULL) {
      seq <- private$run_sequence

      if (!is.null(n)) {
        seq <- seq[seq_len(min(length(seq), as.integer(n)))]
      }

      if (!is.null(min_datetime)) {
        min_datetime <- lubridate::as_datetime(min_datetime)
        seq <- seq[seq >= min_datetime]
      }

      if (!is.null(max_datetime)) {
        max_datetime <- lubridate::as_datetime(max_datetime)
        seq <- seq[seq <= max_datetime]
      }

      seq
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
    run_if = NULL,

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
    returns = NULL,
    next_run = NULL,
    errors = NULL,
    warnings = NULL,
    messages = NULL,

    escape_for_glue = function(msg) {
      msg <- trimws(msg)
      logger::skip_formatter(msg)
    },
    
    run_time_attributes = dplyr::tibble(
      internal_run_id = NA_character_,
      invoked = FALSE,
      success = NA,
      pipeline_started = lubridate::NA_POSIXct_,
      pipeline_ended = lubridate::NA_POSIXct_,
      errors = 0L,
      warnings = 0L,
      messages = 0L,
      run_id = NA_character_,
      input_run_id = NA_character_,
      lineage = NA_character_
    ),

    run_time_artifacts = list(),

    insert_run_time_attributes = function(internal_run_id, attributes) {
      row_idx <- which(private$run_time_attributes$internal_run_id == internal_run_id)
      
      if (length(row_idx) == 0) {
        placeholder_idx <- which(is.na(private$run_time_attributes$internal_run_id))
        
        if (length(placeholder_idx) > 0) {
          row_idx <- placeholder_idx[1]
          private$run_time_attributes$internal_run_id[row_idx] <- internal_run_id
        } else {
          new_row <- dplyr::tibble(internal_run_id = internal_run_id)
          for (attr_name in names(attributes)) {
            new_row[[attr_name]] <- NA
          }
          private$run_time_attributes <- dplyr::bind_rows(private$run_time_attributes, new_row)
          row_idx <- nrow(private$run_time_attributes)
        }
      }
      
      for (i in seq_along(attributes)) {
        private$run_time_attributes[[names(attributes)[i]]][row_idx] <- attributes[[i]]
      }
    },

    error_handler = function(internal_run_id = NULL) {
      function(e) {
        private$errors <- c(private$errors, e$message)
        private$status <- "Error"
        logger::log_error(private$escape_for_glue(conditionMessage(e)), namespace = private$pipe_name)
        run_time_end <- lubridate::now()
        private$run_time_end <- run_time_end
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            pipeline_ended = run_time_end, 
            success = FALSE,
            errors = 1L
          )
        )
      }
    },

    warning_handler = function(internal_run_id = NULL) {
      function(w) {
        warning_log <- logger::log_warn(private$escape_for_glue(conditionMessage(w)), namespace = private$pipe_name)
        private$warnings <- c(private$warnings, w$message)
        private$status <- "Warning"
        cur_n_warnings <- private$run_time_attributes$warnings[private$run_time_attributes$internal_run_id == internal_run_id] %n% 0L
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            warnings = cur_n_warnings + 1L
          )
        )
        invokeRestart("muffleWarning")
      }
    },

    message_handler = function(internal_run_id = NULL) {
      function(m) {
        message_log <- logger::log_info(private$escape_for_glue(conditionMessage(m)), namespace = private$pipe_name)
        private$messages <- c(private$messages, m$message)
        cur_n_messages <- private$run_time_attributes$messages[private$run_time_attributes$internal_run_id == internal_run_id] %n% 0L
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            messages = cur_n_messages + 1L
          )
        )
        invokeRestart("muffleMessage")
      }
    },

    cond_error_handler = function(internal_run_id) {
      function(e) {
        e$message <- paste("Error evaluating condition:", e$message)
        private$errors <- e
        private$status <- "Error"
        logger::log_error(private$escape_for_glue("Error evaluating condition: {conditionMessage(e)}"), namespace = private$pipe_name)
        run_time_end <- lubridate::now()
        private$run_time_end <- run_time_end
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            invoked = TRUE,
            pipeline_ended = run_time_end, 
            errors = 1L
          )
        )
      }
    },

    cond_warning_handler = function(internal_run_id) {
      function(w) {
        warning_log <- logger::log_warn(private$escape_for_glue("Warning evaluating condition: {conditionMessage(w)}"), namespace = private$pipe_name)
        w$message <- paste("Warned while evaluating condition:", w$message)
        private$warnings <- c(private$warnings, w$message)
        private$status <- "Warning"
        cur_n_warnings <- private$run_time_attributes$warnings[private$run_time_attributes$internal_run_id == internal_run_id] %n% 0L
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            warnings = cur_n_warnings + 1L
          )
        )
        invokeRestart("muffleWarning")
      }
    },

    cond_message_handler = function(internal_run_id) {
      function(m) {
        message_log <- logger::log_info(private$escape_for_glue(conditionMessage(m)), namespace = private$pipe_name)
        private$messages <- c(private$messages, m$message)
        private$run_time_attributes[[internal_run_id]]$messages <- c(private$run_time_attributes[[internal_run_id]]$messages, m$message)
        cur_n_messages <- private$run_time_attributes$messages[private$run_time_attributes$internal_run_id == internal_run_id] %n% 0L
        private$insert_run_time_attributes(
          internal_run_id,
          list(
            messages = cur_n_messages + 1L
          )
        )
        invokeRestart("muffleMessage")
      }
    }
  )
)
