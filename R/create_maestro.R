#' Creates a new maestro project
#'
#' @inheritParams create_orchestrator
#'
#' @export
#' @return invisible
create_maestro <- function(path = ".", extension, ...) {

  # ensure path exists
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  create_orchestrator(
    path = file.path(path, "orchestrator"),
    extension = extension,
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
