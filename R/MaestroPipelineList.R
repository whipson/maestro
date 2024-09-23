#' Class for a list of MaestroPipelines
#' A MaestroPipelineList is created when there are multiple maestro pipelines in a
#' single script
#' @keywords internal
MaestroPipelineList <- R6::R6Class(

  "MaestroPipelineList",

  public = list(

    #' @field MaestroPipelines list of pipelines
    #' @field n_pipelines number of pipelines in the list
    MaestroPipelines = list(),
    n_pipelines = 0L,

    #' @description
    #' Create a MaestroPipelineList object
    #' @param MaestroPipelines list of MaestroPipelines
    #' @return MaestroPipelineList
    initialize = function(MaestroPipelines = list()) {
      self$n_pipelines <- length(MaestroPipelines)
      self$MaestroPipelines <- MaestroPipelines
    },

    #' @description
    #' Print the MaestroPipelineList
    #' @return print
    print = function() {
      cli::cli_h3("Maestro Pipelines List with {length(self$MaestroPipelines)} pipeline{?s}")
    },

    #' @description
    #' Add pipelines to the list
    #' @param MaestroPipelines list of MaestroPipelines
    #' @return invisible
    add_pipelines = function(MaestroPipelines = NULL) {
      if ("MaestroPipeline" %in% class(MaestroPipelines)) {
        self$n_pipelines <- self$n_pipelines + length(MaestroPipelines)
        self$MaestroPipelines <- append(self$MaestroPipelines, MaestroPipelines)
      } else {
        purrr::walk(MaestroPipelines$MaestroPipelines, ~{
          self$n_pipelines <- self$n_pipelines + 1
          self$MaestroPipelines <- append(self$MaestroPipelines, .x)
        })
      }
    },

    #' @description
    #' Get names of the pipelines in the list
    #' @return character
    get_pipe_names = function() {
      purrr::map_chr(self$MaestroPipelines, ~.x$get_pipe_name())
    },

    #' @description
    #' Get the schedule as a data.frame
    #' @return data.frame
    get_schedule = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_schedule()) |>
        purrr::list_rbind()
    },

    #' @description
    #' Get a new MaestroPipelineList containing only those pipelines scheduled to run
    #' @param ... arguments passed to self$check_timeliness
    #' @return MaestroPipelineList
    get_timely_pipelines = function(...) {
      dots <- rlang::list2(...)
      timely_pipelines_idx <- do.call(self$check_timeliness, dots)
      MaestroPipelineList$new(self$MaestroPipelines[timely_pipelines_idx])
    },

    #' @description
    #' Check whether pipelines in the list are scheduled to run based on orchestrator frequency and current time
    #' @param ... arguments passed to self$check_timeliness
    #' @return logical
    check_timeliness = function(...) {
      dots <- rlang::list2(...)
      purrr::map_lgl(self$MaestroPipelines, ~do.call(.x$check_timeliness, dots))
    },

    #' @description
    #' Get status of the pipelines as a data.frame
    #' @return data.frame
    get_status = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_status()) |>
        purrr::list_rbind()
    },

    #' @description
    #' Get list of errors from the pipelines
    #' @return list
    get_errors = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_errors()) |>
        purrr::discard(is.null)
    },

    #' @description
    #' Get list of warnings from the pipelines
    #' @return list
    get_warnings = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_warnings()) |>
        purrr::discard(is.null)
    },

    #' @description
    #' Get list of messages from the pipelines
    #' @return list
    get_messages = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_messages()) |>
        purrr::discard(is.null)
    },

    #' @description
    #' Get artifacts (return values) from the pipelines
    #' @return list
    get_artifacts = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_artifacts()) |>
        stats::setNames(self$get_pipe_names()) |>
        purrr::discard(is.null)
    },

    #' @description
    #' Runs all the pipelines in the list
    #' @param ... arguments passed to MaestroPipeline$run
    #' @param cores if using multicore number of cores to run in (uses `furrr`)
    #'
    #' @return invisible
    run = function(..., cores = 1L) {
      dots <- rlang::list2(...)

      # Parallelization
      mapper_fun <- function(...) {
        purrr::map(...)
      }

      if (!is.null(cores)) {
        if (cores < 1 || (cores %% 1) != 0) cli::cli_abort("`cores` must be a positive integer")
        if (cores > 1) {
          tryCatch({
            rlang::check_installed("furrr")
            mapper_fun <- function(...) {
              furrr::future_map(..., .options = furrr::furrr_options(stdout = FALSE))
            }
          }, error = \(e) {
            cli::cli_warn("{.pkg furrr} is required for running on multiple cores.")
          })
        }
      }

      # Run the pipelines
      mapper_fun(
        self$MaestroPipelines,
        purrr::safely(~{
          do.call(.x$run, dots)
        }, quiet = TRUE)
      )

      invisible()
    }
  )
)
