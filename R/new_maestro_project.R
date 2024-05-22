#' Creates a new maestro project
#'
#' @inheritParams create_orchestrator
#'
#' @return invisible
new_maestro_project <- function(extension) {

  create_pipeline(
    pipe_name = "my_pipe"
  )

  create_orchestrator(
    path = "./orchestrator",
    extension = extension,
    open = TRUE
  )
}
