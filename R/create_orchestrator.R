#' Create a new orchestrator
#'
#' @param open whether or not to open the script upon creation
#' @param path file path for the orchestrator script
#' @param type file type for the orchestrator (supports R, Quarto, and RMarkdown)
#' @param quiet whether to silence messages in the console (default = `FALSE`)
#'
#' @return invisible
create_orchestrator <- function(
    path = "./orchestrator",
    type = c("R", "Quarto", "RMarkdown"),
    open = interactive(),
    quiet = FALSE
) {

  type <- match.arg(type, choices = c("R", "Quarto", "RMarkdown"))

  template <- ifelse(type == "R", "orchestrator_template", "orchestrator_template_qmd")

  script <- readLines(system.file(template, package = "maestro")) |>
    paste(collapse = "\n") |>
    glue::glue(
      .open = "{{",
      .close = "}}",
      .null = NULL
    )

  extension <- switch (type,
    R = "R",
    Quarto = "qmd",
    RMarkdown = "Rmd"
  )

  path <- paste0(path, ".", extension)

  if (file.exists(path)) {
    overwrite <- readline(glue::glue("File {path} already exists. Overwrite? [Y/n]: \n"))
    if (tolower(overwrite) != "y") return(invisible())
  }

  writeLines(
    script,
    path
  )

  if (open) {
    rlang::check_installed("rstudioapi")
    rstudioapi::documentOpen(path)
  }

  if(!quiet) {
    cli::cli_alert_success("Created orchestrator at {.file {path}}")
  }
}
