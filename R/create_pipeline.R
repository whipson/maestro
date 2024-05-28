#' Create a new pipeline in a pipelines directory
#'
#' @param pipe_name name of the pipeline and function
#' @param frequency how often the pipeline should run (e.g., hourly, daily, etc.). Fills in maestroFrequency tag
#' @param start_time start time of the pipeline schedule. Fills in maestroStartTime tag
#' @param tz timezone that pipeline will be scheduled in. Fills in maestroTz tag
#' @param log_level log level for the pipeline (e.g., INFO, WARN, ERROR). Fills in maestroLogLevel tag
#' @param open whether or not to open the script upon creation
#' @param quiet whether to silence messages in the console (default = `FALSE`)
#'
#' @return invisible
#' @export
create_pipeline <- function(
    pipe_name,
    pipeline_dir = "pipelines",
    frequency = "day",
    start_time = Sys.Date(),
    tz = "UTC",
    log_level = "INFO",
    quiet = FALSE,
    open = interactive()
  ) {

  # Makes a valid name for a pipe
  pipe_name <- gsub("\\.", "_", make.names(pipe_name))

  script <- readLines(system.file("pipeline_template", package = "maestro")) |>
    paste(collapse = "\n") |>
    glue::glue(
      .open = "{{",
      .close = "}}",
      .null = NULL
    )

  path <- file.path(pipeline_dir, paste0(pipe_name, ".R"))

  if (!dir.exists(pipeline_dir)) {
    dir.create(pipeline_dir)
  }

  if (file.exists(path)) {
    overwrite <- readline(glue::glue("File {path} already exists. Overwrite? [Y/n]: \n"))
    if (tolower(overwrite) != "y") return(invisible())
  }

  writeLines(
    script,
    path
  )

  if (open) {
    rstudioapi::documentOpen(path)
  }

  if(!quiet) {
    cli::cli_alert_success("Created pipeline at {.file {path}}")
  }
}
