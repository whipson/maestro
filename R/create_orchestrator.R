#' Create a new orchestrator
#'
#' @param open whether or not to open the script upon creation
#' @param path file path for the orchestrator script
#' @param extension file extension for the orchestrator (supports R, Quarto, and RMarkdown)
#'
#' @return invisible
#' @export
create_orchestrator <- function(
    path = "./orchestrator",
    extension = c("R", "Quarto", "RMarkdown"),
    open = interactive()
) {

  extension <- tolower(match.arg(extension))

  template <- ifelse(extension == "R", "orchestrator_template", "orchestrator_template_qmd")

  script <- readLines(system.file(template, package = "maestro")) |>
    paste(collapse = "\n") |>
    glue::glue(
      .open = "{{",
      .close = "}}",
      .null = NULL
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
    rstudioapi::documentOpen(path)
  }

  message(glue::glue("Created orchestrator at {path}"))
}
