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

  # Source the script
  tryCatch({
    source(script_path)
  }, error = \(e) {

    cli::cli_abort("Runtime error in {.code {pipe_name}}")
  }, warning = \(w) {
    NULL
  })

  # If it's a function
  if (is_func) {

    args <- formals(pipe_name)

    do.call(pipe_name, args = resources[names(args)])
  }
}
