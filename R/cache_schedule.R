#' Save a schedule to a cache file
#'
#' Serializes a `MaestroSchedule` object to an `.rds` file so it can be
#' reloaded quickly by
#' `build_schedule(from_cache = TRUE)` without re-parsing pipeline scripts.
#'
#' The intended workflow is:
#' 1. On first run (or after any pipeline configuration change), call
#'    `build_schedule()` followed by `cache_schedule()`.
#' 2. On subsequent runs with no configuration changes, call
#'    `build_schedule(from_cache = TRUE)` to skip tag parsing and only
#'    refresh the run sequences.
#'
#' **The cache must be regenerated** (by calling `build_schedule()` +
#' `cache_schedule()` again) whenever any of the following occur:
#'
#' - A pipeline is added, removed, or renamed
#' - Any `@maestro*` tag is modified (frequency, start time, inputs, flags, etc.)
#' - A pipeline script is moved to a different location
#'
#' The cache only stores a snapshot of the schedule configuration; it does not
#' track changes to pipeline scripts automatically.
#'
#' @param schedule object of type `MaestroSchedule`
#'
#' @return path to the cache file (invisibly)
#' @export
#' @examples
#' if (interactive()) {
#'   pipeline_dir <- tempdir()
#'   create_pipeline("my_new_pipeline", pipeline_dir, open = FALSE)
#'   schedule <- build_schedule(pipeline_dir = pipeline_dir)
#'
#'   cache_schedule(schedule)
#'
#'   # Later, load the cached schedule (only safe if no pipeline config has changed)
#'   schedule <- build_schedule(from_cache = TRUE)
#' }
cache_schedule <- function(schedule) {

  if (!"MaestroSchedule" %in% class(schedule)) {
    cli::cli_abort(
      c(
        "Schedule must be an object of {.cls MaestroSchedule} and not {.cls {class(schedule)}}.",
        "i" = "Use {.fn build_schedule} to create a valid schedule."
      ),
      call = rlang::caller_env()
    )
  }

  path <- ".maestro/schedule.rds"

  dir <- dirname(path)
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }

  saveRDS(schedule, file = path)
  cli::cli_inform("Schedule cached to {.file {path}}.")

  invisible(path)
}
