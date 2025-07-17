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
    #' @param network initialize a network
    #' @return MaestroPipelineList
    initialize = function(MaestroPipelines = list(), network = NULL) {
      self$n_pipelines <- length(MaestroPipelines)
      self$MaestroPipelines <- MaestroPipelines
      private$network <- network
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
        self$n_pipelines <- self$n_pipelines + 1
        self$MaestroPipelines <- append(self$MaestroPipelines, MaestroPipelines)
      } else {
        purrr::walk(MaestroPipelines$MaestroPipelines, ~{
          self$n_pipelines <- self$n_pipelines + 1
          self$MaestroPipelines <- append(self$MaestroPipelines, .x)
        })
      }
    },

    #' @description
    #' Get names of the pipelines in the list arranged by priority
    #' @return character
    get_pipe_names = function() {
      purrr::map_chr(self$MaestroPipelines, ~.x$get_pipe_name())
    },

    #' @description
    #' Get a MaestroPipeline by its name
    #' @param pipe_name name of the pipeline
    #' @return MaestroPipeline
    get_pipe_by_name = function(pipe_name) {
      names <- self$get_pipe_names()
      name_idx <- which(names %in% pipe_name)
      if (length(name_idx) == 0) {
        cli::cli_abort("No pipeline named {pipe_name} in {.cls MaestroPipelineList}")
      }
      self$MaestroPipelines[[name_idx]]
    },

    #' @description
    #' Get priorities
    #' @return numeric
    get_priorities = function() {
      purrr::map_dbl(self$MaestroPipelines, ~.x$get_priority())
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
      MaestroPipelineList$new(self$MaestroPipelines[timely_pipelines_idx], network = private$network)
    },

    #' @description
    #' Get pipelines that are primary (i.e., don't have an inputting pipeline)
    #' @return list of MaestroPipelines
    get_primary_pipes = function() {
      network <- self$get_network()
      names <- self$get_pipe_names()
      primary_pipelines_idx <- which(!names %in% network$to)
      self$MaestroPipelines[primary_pipelines_idx]
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
    #' Get run sequences from the pipelines
    #' @return list
    get_run_sequences = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_run_sequence()) |>
        stats::setNames(self$get_pipe_names()) |>
        purrr::discard(is.null)
    },

    #' @description
    #' Get the flags of the pipelines as a named list
    #' @return list
    get_flags = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_flags()) |>
        stats::setNames(self$get_pipe_names())
    },

    #' @description
    #' Get the network structure as a edge list
    #' @return data.frame
    get_network = function() {
      if (!is.null(private$network)) return(private$network)

      network <- dplyr::tibble(
        from = character(),
        to = character()
      )

      if (length(self$MaestroPipelines) > 0) {
        network <- purrr::map(self$MaestroPipelines, ~{
          network_dat <- dplyr::tibble(
            from = character(),
            to = character()
          )
          to <- .x$get_outputs()
          from <- .x$get_inputs()
          this <- .x$get_pipe_name()
          if (!is.null(to)) {
            network_dat <- network_dat |>
              dplyr::bind_rows(
                dplyr::tibble(
                  from = this,
                  to = to
                )
              )
          }

          if (!is.null(from)) {
            network_dat <- network_dat |>
              dplyr::bind_rows(
                dplyr::tibble(
                  from = from,
                  to = this
                )
              )
          }
          network_dat
        }) |>
          purrr::list_rbind() |>
          dplyr::distinct(from, to)
      }

      private$network <- network
      network
    },

    #' @description
    #' Validates whether all inputs and outputs exist and that the network is a valid DAG
    #' @return warning or invisible
    validate_network = function() {

      pipe_names <- self$get_pipe_names()

      inputs <- purrr::map(self$MaestroPipelines, ~.x$get_inputs()) |>
        purrr::set_names(pipe_names) |>
        purrr::keep(~!is.null(.x))

      outputs <- purrr::map(self$MaestroPipelines, ~.x$get_outputs()) |>
        purrr::set_names(pipe_names) |>
        purrr::keep(~!is.null(.x))

      if (length(inputs) > 0) {
        withCallingHandlers({
          purrr::iwalk(inputs, ~{
            if (!all(.x %in% pipe_names)) {
              invalid <- .x[which(!.x %in% pipe_names)]
              cli::cli_abort(
                "Pipeline {.pkg {.y}} references non-existent input pipeline{?s} {.pkg {invalid}}.",
                call = NULL
              )
            }
          })
        }, purrr_error_indexed = function(err) {
          rlang::cnd_signal(err$parent)
        })
      }

      if (length(outputs) > 0) {
        withCallingHandlers({
          purrr::iwalk(outputs, ~{
            if (!all(.x %in% pipe_names)) {
              invalid <- .x[which(!.x %in% pipe_names)]
              cli::cli_abort(
                "Pipeline {.pkg {.y}} references non-existent output pipeline{?s} {.pkg {invalid}}.",
                call = NULL
              )
            }
          })
        }, purrr_error_indexed = function(err) {
          rlang::cnd_signal(err$parent)
        })
      }

      network <- self$get_network()


      if (nrow(network) > 0) {

        # Ensure that the outputs and inputs are reflected in the pipelines
        purrr::walk2(network$from, network$to, ~{
          from_pipe <- self$get_pipe_by_name(.x)
          to_pipe <- self$get_pipe_by_name(.y)

          cur_inputs <- to_pipe$get_inputs()
          cur_outputs <- from_pipe$get_outputs()

          from_pipe$update_outputs(unique(c(cur_outputs, .y)))
          to_pipe$update_inputs(unique(c(cur_inputs, .x)))
        })

        if (!is_valid_dag(network)) {
          cli::cli_abort(
            "Invalid DAG detected. Ensure there are no cycles in the DAG.",
            call = NULL
          )
        }
      }
    },

    #' @description
    #' Runs all the pipelines in the list
    #' @param ... arguments passed to MaestroPipeline$run
    #' @param cores if using multicore number of cores to run in (uses `furrr`)
    #' @param pipes_to_run an optional vector of pipe names to run. If `NULL` defaults to all primary pipelines
    #'
    #' @return invisible
    run = function(..., cores = 1L, pipes_to_run = NULL) {
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

      if (is.null(pipes_to_run)) {
        pipes_to_run <- self$get_primary_pipes()
      }
      network <- self$get_network()

      run_pipe <- function(pipe, .input = NULL, depth = -1, ...) {
        depth <- min(depth + 1, 6)
        do.call(pipe$run, append(dots, list(.input = .input, ...)))
        .input <- pipe$get_artifacts()
        out_names <- network$to[network$from == pipe$get_pipe_name()]
        if (pipe$get_status_chr() == "Error") return(invisible())
        if (length(out_names) == 0) return(invisible())
        for (i in out_names) {
          pipe <- self$get_pipe_by_name(i)
          prepend <- paste0(rep("  ", times = depth), "|-")
          run_pipe(
            pipe,
            .input = .input,
            depth = depth,
            cli_prepend = cli::format_inline(prepend)
          )
        }
      }

      # Run the pipelines
      mapper_fun(
        pipes_to_run,
        purrr::safely(run_pipe, quiet = TRUE)
      )

      invisible()
    }
  ),

  private = list(
    network = NULL
  )
)
