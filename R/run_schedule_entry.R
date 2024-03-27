#' Runs a single pipeline
#'
#' @param script_path path to the script containing the pipeline
#' @param pipe_name name of the pipeline
#' @param is_func whether the pipeline is a function or not
#'
#' @return
run_schedule_entry <- function(script_path, pipe_name, is_func) {

  # Source the script
  tryCatch({
    source(script_path)
  }, error = \(e) {

    # File doesn't exist
    if (grepl(e$message, "cannot open the connection")) {
      cli::cli_abort("{ script_path} does not exist.")
    }
  }, warning = \(w) {
    NULL
  })

  # If it's a function
  if (is_func) {

    args <- formals(pipe_name)

    do.call(pipe_name, args = resources[names(args)])
  }
}
