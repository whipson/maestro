#' Create a new pipeline in a pipelines directory
#'
#' @param pipe_name name of the pipeline and function
#' @param frequency how often the pipeline should run (e.g., hourly, daily, etc.). Fills in maestroFrequency tag
#' @param interval units of frequency between runs (e.g., 1, 2, 7). Fills in maestroFrequency tag
#' @param start_time start time of the pipeline schedule. Fills in maestroStartTime tag
#' @param tz timezone that pipeline will be scheduled in. Fills in maestroTz tag
#' @param open whether or not to open the script upon creation
#'
#' @return invisible
#' @export
create_pipeline <- function(
    pipe_name,
    pipeline_dir = "pipelines",
    frequency = NULL,
    interval = NULL,
    start_time = NULL,
    tz = NULL,
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

  message(glue::glue("Created pipeline at {path}"))
}
