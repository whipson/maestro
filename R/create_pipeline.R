#' Create a new pipeline in a pipelines directory
#'
#' Allows the creation of new pipelines (R scripts) and fills in the maestro tags as specified.
#'
#' @param pipe_name name of the pipeline and function
#' @param pipeline_dir directory containing the pipeline scripts
#' @param frequency how often the pipeline should run (e.g., 1 day, daily, 3 hours, 4 months). Fills in maestroFrequency tag
#' @param start_time start time of the pipeline schedule. Fills in maestroStartTime tag
#' @param tz timezone that pipeline will be scheduled in. Fills in maestroTz tag
#' @param log_level log level for the pipeline (e.g., INFO, WARN, ERROR). Fills in maestroLogLevel tag
#' @param open whether or not to open the script upon creation
#' @param quiet whether to silence messages in the console (default = `FALSE`)
#' @param overwrite whether or not to overwrite an existing pipeline of the same name and location.
#' @param skip whether to skip the pipeline when running in the orchestrator (default = `FALSE`)
#' @param inputs vector of names of pipelines that input into this pipeline (default = `NULL` for no inputs)
#' @param outputs vector of names of pipelines that receive output from this pipeline (default = `NULL` for no outputs)
#' @param priority a single positive integer corresponding to the order in which this pipeline will be invoked in the presence of other simultaneously invoked pipelines.
#'
#' @return invisible
#' @export
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline(
#'     "extract_data",
#'     pipeline_dir = pipeline_dir,
#'     frequency = "1 hour",
#'     open = FALSE,
#'     quiet = TRUE,
#'     overwrite = TRUE
#'   )
#'
#'   create_pipeline(
#'     "new_job",
#'     pipeline_dir = pipeline_dir,
#'     frequency = "20 minutes",
#'     start_time = as.POSIXct("2024-06-21 12:20:00"),
#'     log_level = "ERROR",
#'     open = FALSE,
#'     quiet = TRUE,
#'     overwrite = TRUE
#'   )
#' }
create_pipeline <- function(
    pipe_name,
    pipeline_dir = "pipelines",
    frequency = "1 day",
    start_time = Sys.Date(),
    tz = "UTC",
    log_level = "INFO",
    quiet = FALSE,
    open = interactive(),
    overwrite = FALSE,
    skip = FALSE,
    inputs = NULL,
    outputs = NULL,
    priority = NULL
  ) {

  skip <- if (skip) {
    "\n#' @maestroSkip"
  } else {
    ""
  }

  inputs <- if (!is.null(inputs)) {
    paste("\n#'", paste(inputs, collapse = " "))
  } else {
    ""
  }

  outputs <- if (!is.null(outputs)) {
    paste("\n#'", paste(outputs, collapse = " "))
  } else {
    ""
  }

  priority <- if (!is.null(priority)) {
    if (!(rlang::is_scalar_integerish(priority) && priority > 0)) {
      cli::cli_abort(
        c("`priority` must be a single positive whole number."),
        call = NULL
      )
    }
    paste("\n#' @maestroPriority", priority)
  } else {
    ""
  }

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
    if (!overwrite) {
      cli::cli_abort(
        c("File {.file {path}} already exists.",
          "Set {.code create_pipeline(overwrite = TRUE)} to overwrite anyway."),
        call = NULL
      )
    } else {
      if (!quiet) cli::cli_alert_warning("Overwriting existing pipeline at {.file {path}}.")
    }
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
