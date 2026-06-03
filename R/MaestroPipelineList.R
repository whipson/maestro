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
      if (inherits(MaestroPipelines, "MaestroPipeline")) {
        self$n_pipelines <- self$n_pipelines + 1
        self$MaestroPipelines <- append(self$MaestroPipelines, MaestroPipelines)
      } else {
        purrr::walk(MaestroPipelines$MaestroPipelines, ~{
          self$n_pipelines <- self$n_pipelines + 1
          self$MaestroPipelines <- append(self$MaestroPipelines, .x)
        })
      }
      invisible()
    },

    #' @description
    #' Update pipelines in a list
    #' @param MaestroPipelines list of MaestroPipelines
    #' @return invisible
    update_pipelines = function(MaestroPipelines = NULL) {
      pipe_names <- self$get_pipe_names()
      if (inherits(MaestroPipelines, "MaestroPipeline")) {
        pipe_to_update_name <- MaestroPipelines$get_pipe_name()
        idx_to_update <- which(pipe_names == pipe_to_update_name)
        self$MaestroPipelines[[idx_to_update]] <- MaestroPipelines
      } else {
        purrr::walk(MaestroPipelines, ~{
          pipe_to_update_name <- .x$get_pipe_name()
          idx_to_update <- which(pipe_names == pipe_to_update_name)
          self$MaestroPipelines[[idx_to_update]] <- .x
        })
      }
      invisible()
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
    #' Get a MaestroPipelineList with selected pipelines
    #' @param pipe_names names of the pipelines
    #' @return MaestroPipelineList
    get_pipes_by_name = function(pipe_names) {
      names <- self$get_pipe_names()
      names_idx <- which(names %in% pipe_names)
      if (length(names_idx) == 0) {
        cli::cli_abort("No pipelines named {pipe_names} in {.cls MaestroPipelineList}")
      }
      self$MaestroPipelines[names_idx]
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
        purrr::set_names(self$get_pipe_names()) |> 
        purrr::discard(is.null)
    },

    #' @description
    #' Get list of warnings from the pipelines
    #' @return list
    get_warnings = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_warnings()) |>
        purrr::set_names(self$get_pipe_names()) |> 
        purrr::discard(is.null)
    },

    #' @description
    #' Get list of messages from the pipelines
    #' @return list
    get_messages = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_messages()) |>
        purrr::set_names(self$get_pipe_names()) |> 
        purrr::discard(is.null)
    },

    #' @description
    #' Get artifacts (return values) from the pipelines
    #' @return list
    get_artifacts = function() {
      purrr::map(self$MaestroPipelines, ~.x$get_artifacts()) |>
        stats::setNames(self$get_pipe_names()) |>
        purrr::discard(is.null) |> 
        purrr::discard(~length(.x) == 0)
    },

    #' @description
    #' Get run sequences from the pipelines
    #' @param n optional sequence limit
    #' @param min_datetime optional minimum datetime
    #' @param max_datetime optional maximum datetime
    #' @return list
    get_run_sequences = function(n = NULL, min_datetime = NULL, max_datetime = NULL) {
      purrr::map(self$MaestroPipelines, ~.x$get_run_sequence(n = n, min_datetime = min_datetime, max_datetime = max_datetime)) |>
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

      # Validate each() and collect() arity
      withCallingHandlers({
        purrr::walk(self$MaestroPipelines, ~{
          pipe <- .x
          if (pipe$get_is_each()) {
            n <- length(pipe$get_inputs())
            if (n != 1L) {
              cli::cli_abort(
                "Pipeline {.pkg {pipe$get_pipe_name()}} uses {.code each()} but references {n} input{?s}. {.code each()} requires exactly one input pipeline.",
                call = NULL
              )
            }
          }
          if (pipe$get_is_collect()) {
            n <- length(pipe$get_inputs())
            if (n < 2L) {
              # A single each() upstream is valid (dynamic fan-out → fan-in)
              single_is_each <- n == 1L &&
                pipe$get_inputs()[[1]] %in% pipe_names &&
                self$get_pipe_by_name(pipe$get_inputs()[[1]])$get_is_each()
              if (!single_is_each) {
                cli::cli_abort(
                  "Pipeline {.pkg {pipe$get_pipe_name()}} uses {.code collect()} but references {n} input{?s}. {.code collect()} requires at least two input pipelines or a single {.code each()} pipeline.",
                  call = NULL
                )
              }
            }
          }
        })
      }, purrr_error_indexed = function(err) {
        rlang::cnd_signal(err$parent)
      })

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

      if (cores > 1) {
        mapper_fun <- function(...) {
          furrr::future_map(
            ..., 
            .options = furrr::furrr_options(
              packages = c("maestro", "logger"),
              stdout = FALSE, 
              seed = NULL
            )
          )
        }
      }

      if (is.null(pipes_to_run)) {
        pipes_to_run <- self$get_primary_pipes()
      } else {
        pipes_to_run <- self$get_pipes_by_name(pipes_to_run)
      }
      network <- self$get_network()

      run_pipe <- function(
        pipe, 
        .input = NULL, 
        depth = -1, 
        input_run_id = NA_character_, 
        run_results = list(),
        lineage = character(),
        iter = NULL,
        pre_error = NULL,
        ...
      ) {

        run_id <- make_id()
        depth <- min(depth + 1, 6)
        
        tryCatch({
          do.call(
            pipe$run, 
            append(
              dots, 
              list(
                .input = .input, 
                run_id = run_id, 
                input_run_id = input_run_id,
                depth = depth,
                lineage = lineage,
                iter = iter,
                pre_error = pre_error
              )
            )
          )
        }, error = \(e) {
          return(pipe)
        })
        
        lineage <- append(lineage, pipe$get_pipe_name())
        run_results <- append(run_results, pipe)
        
        .input <- pipe$get_returns()
        out_names <- network$to[network$from == pipe$get_pipe_name()]
        
        if (pipe$get_status_chr() %in% c("Error", "Not Run")) {
          return(run_results)
        }
        
        if (length(out_names) == 0) return(run_results)

        for (i in out_names) {
          pipe <- self$get_pipe_by_name(i)

          # For collect() fan-in, resolve_collect_input checks all readiness
          # guards and returns the named .input list, or NULL to skip.
          # Guard: also skip if already invoked (fires exactly once).
          collect_input <- NULL
          if (pipe$get_is_collect()) {
            if (pipe$get_status_chr() != "Not Run") next
            collect_input <- private$resolve_collect_input(pipe, network)
            if (is.null(collect_input)) next
          }

          # Use the collected named list as .input when this is a collect pipe,
          # otherwise fall through to the normal .input from the current pipe.
          effective_input <- if (!is.null(collect_input)) collect_input else .input

          if (pipe$get_is_each()) {
            iterate_over <- pipe$get_iterate_over()
            pre_error <- NULL
            scatter_input <- if (!is.null(iterate_over)) {
              scatter_vec <- eval(str2lang(iterate_over), envir = list(.input = effective_input))
              if (is.null(scatter_vec)) {
                field <- sub("^\\.input\\$", "", iterate_over)
                pre_error <- simpleError(
                  paste0(
                    "Field '", field, "' specified in @maestroIterateOver not found in ",
                    "the output of the upstream pipeline."
                  )
                )
                # Dummy output that won't get seen
                list(structure(list("0"), names = "N"))
              } else {
                field <- sub("^\\.input\\$", "", iterate_over)
                iter_names <- if (!is.null(names(scatter_vec))) {
                  names(scatter_vec)
                } else if (is.atomic(scatter_vec) && all(lengths(scatter_vec) == 1)) {
                  as.character(scatter_vec)
                } else {
                  as.character(seq_along(scatter_vec))
                }
                purrr::imap(scatter_vec, \(item, idx) {
                  inp <- effective_input
                  inp[[field]] <- item
                  inp
                }) |>
                  stats::setNames(iter_names)
              }
            } else {
              effective_input
            }
            pipe$set_n_expected_iterations(length(scatter_input))
            purrr::iwalk(scatter_input, ~{
              res <- run_pipe(
                pipe,
                .input = .x,
                depth = depth,
                run_id = run_id,
                input_run_id = run_id,
                run_results = run_results,
                lineage = lineage,
                iter = .y,
                pre_error = pre_error
              )

              run_results <<- append(run_results, res)
            })
          } else {
            run_results <- run_pipe(
              pipe,
              .input = effective_input,
              depth = depth,
              run_id = run_id,
              input_run_id = run_id,
              run_results = run_results,
              lineage = lineage,
              pre_error = pre_error
            )
          }
        }

        run_results
      }
      
      # Run the pipelines
      run_res <- mapper_fun(
        pipes_to_run,
        purrr::safely(~{
          run_pipe(
            .x, 
            run_results = list(),
            lineage = character()
          )
        }, quiet = TRUE)
      )

      purrr::map(run_res, "result") |>
        purrr::list_flatten()
    },

    #' @description
    #' Run any collect pipelines that are ready but were skipped during a
    #' parallel run. Called on the main process after update_pipelines() has
    #' synced worker state back. Uses run_pipe internally so that the collect
    #' pipe's own downstream outputs are recursed into normally.
    #' @param ... arguments forwarded to MaestroPipeline$run (same dots as run())
    #' @return list of MaestroPipeline objects that were run
    run_pending_collects = function(...) {
      dots <- rlang::list2(...)
      network <- self$get_network()

      collect_pipes <- purrr::keep(self$MaestroPipelines, ~.x$get_is_collect())
      pending <- purrr::keep(collect_pipes, ~.x$get_status_chr() == "Not Run")
      if (length(pending) == 0) return(invisible(list()))

      # Reconstruct a run_pipe closure that mirrors the one inside run(),
      # giving full recursive output traversal for the collect pipe and any
      # pipelines downstream of it.
      run_pipe <- function(
        pipe,
        .input = NULL,
        depth = -1,
        input_run_id = NA_character_,
        run_results = list(),
        lineage = character(),
        iter = NULL,
        pre_error = NULL,
        ...
      ) {
        run_id <- make_id()
        depth <- min(depth + 1, 6)

        tryCatch({
          do.call(
            pipe$run,
            append(
              dots,
              list(
                .input = .input,
                run_id = run_id,
                input_run_id = input_run_id,
                depth = depth,
                lineage = lineage,
                iter = iter,
                pre_error = pre_error
              )
            )
          )
        }, error = \(e) return(pipe))

        lineage <- append(lineage, pipe$get_pipe_name())
        run_results <- append(run_results, pipe)

        .input <- pipe$get_returns()
        out_names <- network$to[network$from == pipe$get_pipe_name()]

        if (pipe$get_status_chr() %in% c("Error", "Not Run")) return(run_results)
        if (length(out_names) == 0) return(run_results)

        for (i in out_names) {
          pipe <- self$get_pipe_by_name(i)

          collect_input <- NULL
          if (pipe$get_is_collect()) {
            if (pipe$get_status_chr() != "Not Run") next
            collect_input <- private$resolve_collect_input(pipe, network)
            if (is.null(collect_input)) next
          }

          effective_input <- if (!is.null(collect_input)) collect_input else .input

          run_results <- run_pipe(
            pipe,
            .input = effective_input,
            depth = depth,
            input_run_id = run_id,
            run_results = run_results,
            lineage = lineage
          )
        }

        run_results
      }

      purrr::map(pending, ~{
        collect_input <- private$resolve_collect_input(.x, network)
        if (is.null(collect_input)) return(list())
        run_pipe(.x, .input = collect_input, run_results = list(), lineage = character())
      }) |>
        purrr::list_flatten()
    },
    
    #' @description
    #' Resets the run time attributes
    reset_pipelines = function() {
      purrr::walk(self$MaestroPipelines, ~.x$reset_run_time_attributes())
    }
  ),

  private = list(
    network = NULL,

    # Returns the named .input list for a collect pipe if all its inputs are
    # ready, or NULL if the collect should not fire yet / at all.
    resolve_collect_input = function(pipe, network) {
      i <- pipe$get_pipe_name()
      in_names <- network$from[network$to == i]
      in_pipes <- purrr::map(in_names, self$get_pipe_by_name) |>
        stats::setNames(in_names)

      # All non-each inputs must have succeeded
      non_each_not_ready <- purrr::map_lgl(in_pipes, ~{
        !.x$get_is_each() && .x$get_status_chr() != "Success"
      })
      if (any(non_each_not_ready)) return(NULL)

      # Each inputs must have all iterations finished (succeeded or errored)
      each_not_ready <- purrr::map_lgl(in_pipes, ~{
        if (!.x$get_is_each()) return(FALSE)
        # Prefer the count recorded by set_n_expected_iterations() — it is
        # always correct even when @maestroIterateOver sub-selects a field
        # (in that case length(scatter_source$get_returns()) gives the number
        # of fields in the upstream list, not the fan-out width).
        expected_n <- .x$get_n_expected_iterations()
        if (is.null(expected_n)) {
          # Fallback for each() without @maestroIterateOver: derive from the
          # scatter source's return value (plain vector/list fan-out).
          scatter_source_name <- network$from[network$to == .x$get_pipe_name()]
          if (length(scatter_source_name) == 0) return(FALSE)
          scatter_source <- self$get_pipe_by_name(scatter_source_name[[1]])
          expected_n <- length(scatter_source$get_returns())
        }
        finished_n <- .x$get_n_invocations()
        finished_n < expected_n
      })
      if (any(each_not_ready)) return(NULL)

      # Skip if every iteration of every each input errored
      each_all_failed <- purrr::map_lgl(in_pipes, ~{
        .x$get_is_each() && .x$get_n_artifacts() == 0L
      })
      if (any(each_all_failed)) return(NULL)

      purrr::map(in_pipes, ~{
        if (.x$get_is_each()) .x$get_all_returns() else .x$get_returns()
      }) |>
        stats::setNames(in_names)
    }
  )
)
