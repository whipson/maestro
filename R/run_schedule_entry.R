#' Runs a single pipeline
#'
#' @param script_path path to the script containing the pipeline
#' @param pipe_name name of the pipeline
#' @param resources list of resources for the pipeline
#' @param log_file path to log file
#' @param log_level log level
#'
#' @return invisible
run_schedule_entry <- function(
    script_path,
    pipe_name,
    resources = list(),
    log_file = tempfile(),
    log_level = "INFO"
  ) {

  # Check that it's an R script
  if (!grepl(".*.R$", script_path)) {
    cli::cli_abort(
      c("Script must be an R script, but {.emph {script_path}} is not.",
        "i" = "Run {.fn build_schedule} to ensure schedule is up-to-date")
    )
  }

  # Check that the script exists
  if (!file.exists(script_path)) {
    cli::cli_abort(
      c("Script {.emph {script_path}} not found.",
        "i" = "Run {.fn build_schedule} to ensure schedule is up-to-date")
    )
  }

  # Set the logger to null - we just want the text in a variable
  logger::log_threshold(level = log_level, namespace = pipe_name)
  logger::log_appender(appender = logger::appender_file(log_file), namespace = pipe_name)
  logger::log_layout(maestro_logger, namespace = pipe_name)

  warnings_vec <- NULL
  messages_vec <- NULL

  error_handler <- function(e) {
    logger::log_error(conditionMessage(e), namespace = pipe_name)
  }

  warning_handler <- function(w) {
    warning_log <- logger::log_warn(conditionMessage(w), namespace = pipe_name)
    warnings_vec <<- c(warnings_vec, warning_log$default$record)
    invokeRestart("muffleWarning")
  }

  message_handler <- function(m) {
    message_log <- logger::log_info(conditionMessage(m), namespace = pipe_name)
    messages_vec <<- c(messages_vec, message_log$default$record)
    invokeRestart("muffleMessage")
  }

  run_env <- new.env()

  # Source the script
  logger::log_info("Sourcing script {script_path}", namespace = pipe_name)
  tryCatch({
    source(script_path, local = run_env)
  }, error = \(e) {
    logger::log_error(conditionMessage(e), namespace = pipe_name)
    cli::cli_abort("Error sourcing {.code {pipe_name}}")
  }, warning = \(w) {
    logger::log_warn(conditionMessage(w), namespace = pipe_name)
    NULL
  })

  args <- formals(pipe_name, envir = run_env)

  logger::log_info("Started", namespace = pipe_name)

  withCallingHandlers(
    do.call(pipe_name, args = resources[names(args)], envir = run_env),
    error = error_handler,
    warning = warning_handler,
    message = message_handler
  )

  logger::log_info("Ended", namespace = pipe_name)

  list(
    warnings = warnings_vec,
    messages = messages_vec
  )
}
