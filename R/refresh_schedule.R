#' Refresh the run sequences of a cached schedule
#'
#' Updates the internally precomputed run sequences for all pipelines in a
#' `MaestroSchedule` object without re-parsing any pipeline scripts or tags.
#' This is called automatically when using `build_schedule(from_cache = ...)`,
#' but can also be called directly when you hold a long-lived schedule object
#' and want to freshen its future run times.
#'
#' **This function only refreshes run sequences.** It does not detect or apply
#' any changes to pipeline scripts or `@maestro*` tags. If pipelines have been
#' added, removed, renamed, or had their tags modified since the schedule was
#' last built, those changes will not be reflected. Use `build_schedule()` +
#' `cache_schedule()` to rebuild and re-cache after any configuration change.
#'
#' @param schedule object of type `MaestroSchedule`
#' @param quiet silence console messages (default `FALSE`)
#'
#' @return `MaestroSchedule` (invisibly)
#' @export
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   # Refresh run sequences without re-parsing scripts.
#'   # Only safe if no pipeline configuration has changed.
#'   refresh_schedule(schedule)
#' }
refresh_schedule <- function(schedule, quiet = FALSE) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c(
        "Schedule must be an object of {.cls MaestroSchedule} and not {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."
      ),
      call = rlang::caller_env()
    )
  }

  n <- schedule$PipelineList$n_pipelines

  if (n == 0) {
    if (!quiet) cli::cli_inform("No pipelines in schedule. Nothing to refresh.")
    return(invisible(schedule))
  }

  purrr::walk(
    schedule$PipelineList$MaestroPipelines,
    ~.x$refresh_run_sequence()
  )

  if (!quiet) {
    cli::cli_inform(
      "Refreshed run sequence{?s} for {n} pipeline{?s}."
    )
  }

  invisible(schedule)
}
