#' Creates a new maestro project
#'
#' @inheritParams create_orchestrator
#' @param ... unused
#'
#' @export
#' @return invisible
#' @examples
#'
#' # Creates a new maestro project with an R orchestrator
#' new_proj_dir <- tempdir()
#' create_maestro(new_proj_dir, type = "R")
#'
#' create_maestro(new_proj_dir, type = "Quarto")
create_maestro <- function(path = ".", type = "R", ...) {

  type <- match.arg(type, choices = c("R", "Quarto", "RMarkdown"))

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  create_orchestrator(
    path = file.path(path, "orchestrator"),
    type = type,
    open = FALSE,
    quiet = TRUE
  )

  create_pipeline(
    pipe_name = "my_pipe",
    pipeline_dir = file.path(path, "pipelines"),
    open = FALSE,
    quiet = TRUE
  )
}
