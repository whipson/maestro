#' Special type of MaestroPipeline allowing for DAG pipelines
#' A MaestroPipelineDag is for multiple pipelines chained together
#' @keywords internal
#' @importClassesFrom maestro MaestroPipeline
#' @importMethodsFrom maestro MaestroPipeline
#' @name MaestroPipelineDag
NULL

MaestroPipelineDag <- R6::R6Class(

  "MaestroPipelineDag",

  inherit = MaestroPipeline,

  #' @field adjacency_list adjacency list data.frame defining the ordering of the pipelines
  #' @field pipeline_ids data.frame linking a pipeline name to an integer id
  public = list(
    adjacency_list = data.frame(
      from = NA_integer_,
      to = NA_integer_
    ),
    pipeline_ids = data.frame(
      pipe_name = NA_character_,
      id = NA_integer_
    ),

    #' @description
    #' Runs the pipeline
    #' @param resources named list of arguments and values to pass to the pipeline
    #' @param log_file path to the log file for logging
    #' @param quiet whether to silence console output
    #' @param log_file_max_bytes maximum bytes of the log file before trimming
    #' @param ... additional arguments (unused)
    #'
    #' @return invisible
    run = function(
      resources = list(),
      log_file = tempfile(),
      quiet = FALSE,
      log_file_max_bytes = 1e6,
      ...
    ) {


    }
  )
)
