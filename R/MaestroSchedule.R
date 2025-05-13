#' Class for a schedule of pipelines
#' @import R6 tictoc utils logger lifecycle
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#' }
MaestroSchedule <- R6::R6Class(

  "MaestroSchedule",

  public = list(

    #' @field PipelineList object of type MaestroPipelineList
    PipelineList = NULL,

    #' @description
    #' Create a MaestroSchedule object
    #' @param Pipelines list of MaestroPipelines
    #' @return MaestroSchedule
    initialize = function(
      Pipelines = NULL
    ) {
      self$PipelineList <- MaestroPipelineList$new()
      pipeline_list <- purrr::map(Pipelines, ~.x$MaestroPipelines) |>
        purrr::list_flatten()
      priorities <- purrr::map(pipeline_list, ~.x$get_priority()) |>
        purrr::list_c()
      if (length(priorities) == 0) priorities <- list()
      pipeline_list <- pipeline_list[order(priorities)]
      for (pipeline in pipeline_list) {
        self$PipelineList$add_pipelines(pipeline)
      }
    },

    #' @description
    #' Print the schedule object
    #' @return print
    print = function() {
      cli::cli_h3("Maestro Schedule with {length(self$PipelineList$MaestroPipelines)} pipeline{?s}: ")
      switch (private$sch_status,
        `Not Run` = cli::cli_li(cli::col_magenta(private$sch_status)),
        `Success` = cli::cli_li(cli::col_green(private$sch_status)),
        `Warning` = cli::cli_li(cli::col_yellow(private$sch_status)),
        `Error` = cli::cli_li(cli::col_red(private$sch_status)),
        cli::cli_li("Unknown")
      )
    },

    #' @description
    #' Run a MaestroSchedule
    #' @param ... arguments passed to MaestroPipelineList$run
    #' @param quiet whether or not to silence console messages
    #' @param run_all run all pipelines regardless of the schedule (default is `FALSE`) - useful for testing.
    #' @param n_show_next show the next n scheduled pipes
    #'
    #' @return invisible
    run = function(..., quiet = FALSE, run_all = FALSE, n_show_next = 5) {

      dots <- rlang::list2(..., quiet = quiet)

      if (self$PipelineList$n_pipelines == 0) {
        cli::cli_inform("No pipelines in the schedule. Nothing to do.")
        return(invisible())
      }

      tryCatch({

        # Check the timeliness of the pipelines
        pipes_to_run <- self$PipelineList
        if (!run_all) {
          pipes_to_run <- do.call(pipes_to_run$get_timely_pipelines, dots)
        }

        if (!quiet) {
          cli::cli_h3(
            "[{format(lubridate::now(), '%Y-%m-%d %H:%M:%S')}]
        Running pipelines {cli::col_green(cli::symbol$play)}")
        }

        tictoc::tic(quiet = quiet)
        do.call(pipes_to_run$run, dots)
        elapsed <- tictoc::toc(quiet = TRUE)

        if (!quiet) {
          cli::cli_h3(
            "[{format(lubridate::now(), '%Y-%m-%d %H:%M:%S')}]
          Pipeline execution completed {cli::col_silver(cli::symbol$stop)} | {elapsed$callback_msg}")
        }

        run_errors <- self$PipelineList$get_errors()
        run_warnings <- self$PipelineList$get_warnings()
        run_messages <- self$PipelineList$get_messages()

        # For access via last_run_*
        maestro_pkgenv$last_run_errors <- run_errors
        maestro_pkgenv$last_run_warnings <- run_warnings
        maestro_pkgenv$last_run_messages <- run_messages

        status_table <- self$PipelineList$get_status()

        # Get the number of statuses
        total <- nrow(status_table)
        invoked <- sum(status_table$invoked)
        error_count <- length(run_errors)
        skip_count <- sum(!status_table$invoked)
        success_count <- invoked - error_count
        warning_count <- length(run_warnings)

        if (!quiet) {
          cli::cli_text(
            "
        {cli::col_green(cli::symbol$tick)} {success_count} success{?es} |
        {cli::col_black(cli::symbol$arrow_right)} {skip_count} skipped |
        {cli::col_magenta('!')} {warning_count} warning{?s} |
        {cli::col_red(cli::symbol$cross)} {error_count} error{?s} |
        {cli::col_cyan(cli::symbol$square_small_filled)} {total} total
        "
          )

          if (error_count > 0) {
            cli::cli_alert_danger(
              "Use {.fn last_run_errors} to show pipeline errors."
            )
          }

          if (warning_count > 0) {
            cli::cli_alert_warning(
              "Use {.fn last_run_warnings} to show pipeline warnings."
            )
          }

          cli::cli_rule()

          # Output for showing next pipelines schedule
          if (!run_all && n_show_next > 0 && nrow(status_table) > 0) {

            next_runs_cli <- status_table |>
              dplyr::filter(!is.na(next_run)) |>
              dplyr::arrange(next_run) |>
              utils::head(n = n_show_next)

            cli::cli_h3("Next scheduled pipelines {cli::col_cyan(cli::symbol$pointer)}")
            next_run_strs <- glue::glue("{next_runs_cli$pipe_name} | {next_runs_cli$next_run}")
            cli::cli_text("Pipe name | Next scheduled run")
            cli::cli_ul(next_run_strs)
          }
        }
      }, error = function(e) {
        private$sch_status <- "Error"
        cli::cli_abort(
          "Failed to execute orchestrator with error {e}"
        )
      }, warning = function(w) {
        private$sch_status <- "Warning"
        cli::cli_warn(
          "Orchestrator warned with {w}"
        )
      })
      private$sch_status <- "Success"

      return(invisible())
    },

    #' @description
    #' Get the schedule as a data.frame
    #' @return data.frame
    get_schedule = function() {
      self$PipelineList$get_schedule()
    },

    #' @description
    #' Get status of the pipelines as a data.frame
    #' @return data.frame
    get_status = function() {
      self$PipelineList$get_status()
    },

    #' @description
    #' Get artifacts (return values) from the pipelines
    #' @return list
    get_artifacts = function() {
      self$PipelineList$get_artifacts()
    },

    #' @description
    #' Get the network structure of the pipelines as an edge list (will be empty if there are no DAG pipelines)
    #' @return data.frame
    get_network = function() {
      self$PipelineList$get_network()
    },

    #' @description
    #' Get all pipeline flags as a long data.frame
    #' @return data.frame
    get_flags = function() {
      flag_list <- self$PipelineList$get_flags()
      purrr::imap(flag_list, ~{
        dplyr::tibble(
          pipe_name = .y,
          flag = .x
        )
      }) |>
        purrr::list_rbind()
    },

    #' @description
    #' Visualize the DAG relationships between pipelines in the schedule
    #' @return interactive visualization
    show_network = function() {

      pipe_names <- self$PipelineList$get_pipe_names()

      if (length(pipe_names) == 0) cli::cli_abort("No pipelines in schedule.", call = NULL)

      rlang::check_installed("DiagrammeR")

      net <- self$get_network()

      nodes_df <- dplyr::tibble(
        name = pipe_names
      ) |>
        dplyr::mutate(id = 1:dplyr::n())

      edges_df <- net |>
        dplyr::mutate(
          from = purrr::map_int(from, ~nodes_df$id[nodes_df$name == .x]),
          to = purrr::map_int(to, ~nodes_df$id[nodes_df$name == .x])
        )

      node <- DiagrammeR::create_node_df(n = nrow(nodes_df), label = nodes_df$name)
      edge <- DiagrammeR::create_edge_df(from = edges_df$from, to = edges_df$to)
      g <- DiagrammeR::create_graph(node, edge)
      DiagrammeR::render_graph(g, "tree")
    }
  ),

  private = list(
    sch_status = "Not Run"
  )
)
