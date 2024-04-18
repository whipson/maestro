#' Runs a single pipeline
#'
#' @param script_path path to the script containing the pipeline
#' @param pipe_name name of the pipeline
#' @param is_func whether the pipeline is a function or not
#' @param resources list of resources for the pipeline
#'
#' @return
run_schedule_entry <- function(script_path, pipe_name, is_func, resources = list()) {

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

  warnings_vec <- NULL

  # Define a handler for warnings
  warning_handler <- function(w) {
    # Append the warning message to the list
    warnings_vec <<- c(warnings_vec, w$message)
    # Continue execution after capturing the warning
    invokeRestart("muffleWarning")
  }

  run_env <- new.env()

  # Source the script
  tryCatch({
    source(script_path, local = run_env)
  }, error = \(e) {

    cli::cli_abort("Runtime error in {.code {pipe_name}}")
  }, warning = \(w) {
    NULL
  })

  args <- formals(pipe_name, envir = run_env)

  withCallingHandlers(
    do.call(pipe_name, args = resources[names(args)], envir = run_env),
    warning = warning_handler
  )

  warnings_vec
}
