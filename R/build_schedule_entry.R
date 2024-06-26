#' Create schedule table entry from a script
#'
#' @param script_path path to script
#'
#' @return data.frame row
build_schedule_entry <- function(script_path) {

  # Current list of maestro tags and their equivalent table names
  maestro_tag_names <- list(
    frequency = "maestroFrequency",
    start_time = "maestroStartTime",
    tz = "maestroTz",
    skip = "maestroSkip",
    log_level = "maestroLogLevel"
  )

  # Get all the roxygen tags - this actually executes the script, which is fine
  # if it's functions but can be problematic if it includes other code that
  # evaluates immediately
  tag_list <- tryCatch({
    parse_env <- new.env()
    parse <- function() roxygen2::parse_file(script_path)
    environment(parse) <- parse_env
    parse()
  }, error = \(e) {
    cli::cli_abort(
      c("Could not build schedule entry with error: {e$message}",
        "i" = "Pipeline scripts should not typically include code that's run
        outside of a function. Be sure to wrap code in a function block."),
      call = NULL
    )
  }, warning = \(w) {
    cli::cli_abort(w$message, call = NULL)
  }) |>
    suppressMessages()

  # Get specifically the tags used by maestro
  maestro_tag_vals <- purrr::map(tag_list, ~{
    tag <- .x
    val <- purrr::map(
      maestro_tag_names,
      ~{
        val <- roxygen2::block_get_tag_value(tag, .x)
        ifelse(is.null(val), NA, val)
      }
    )
    val
  })

  if (length(maestro_tag_vals) == 0) {
    cli::cli_abort(
      c("No {.pkg maestro} tags present in {basename(script_path)}.",
        "i" = "A valid pipeline must have at least one function with one or
        more {.pkg maestro} tags: e.g., `#' @maestroFrequency 1 day`."),
      call = NULL
    )
  }

  # Get pipe names from the function name and check
  pipe_names <- purrr::imap(tag_list, ~{

    obj_class <- class(.x$object)

    # Check that it is a function
    if (!"function" %in% obj_class) {
      cli::cli_abort(
        c("{basename(script_path)} line {(.x$line)} has tags but no function. Be sure place
          tags above the function you want to schedule."),
        call = NULL
      )
    }

    # Return the name
    .x$object$topic
  })

  # Create table entries
  table_entities <- purrr::map2(pipe_names, maestro_tag_vals, ~{
    dplyr::tibble(
      script_path = script_path,
      pipe_name = .x,
      !!!.y
    )
  }) |>
    purrr::list_rbind()

  # Create units and n
  nunits <- purrr::map(table_entities$frequency, purrr::possibly(~{
    parse_rounding_unit(.x)
  }, otherwise = list(n = NA, unit = NA)))

  table_entities <- table_entities |>
    dplyr::mutate(
      frequency_n = purrr::map_int(nunits, ~.x$n),
      frequency_unit = purrr::map_chr(nunits, ~.x$unit)
    )

  table_entities
}
