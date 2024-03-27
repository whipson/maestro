#' Create schedule table entry from a script
#'
#' @param script_path path to script
#'
#' @return data.frame row
build_schedule_entry <- function(script_path) {

  # Current list of baton tags and their equivalent table names
  baton_tag_names <- list(
    frequency = "batonFrequency",
    interval = "batonInterval",
    start_time = "batonStartTime",
    tz = "batonTz",
    skip = "batonSkip"
  )

  # Get all the roxygen tags
  tag_list <- tryCatch({
    roxygen2::parse_file(script_path)
  }, error = \(e) {
    cli::cli_abort(e$message, call = NULL)
  }, warning = \(w) {
    cli::cli_abort(w$message, call = NULL)
  })

  # Get specifically the tags used by baton
  baton_tag_vals <- purrr::map(tag_list, ~{
    tag <- .x
    val <- purrr::map(
      baton_tag_names,
      ~{
        val <- roxygen2::block_get_tag_value(tag, .x)
        ifelse(is.null(val), NA, val)
      }
    )
    val
  })

  if(length(baton_tag_vals) == 0) {
    cli::cli_abort(
      c("No functions with {.pkg baton} tags present in {basename(script_path)}.",
        "i" = "A valid pipeline must have at least one function with one or
        more {.pkg baton} tags: e.g., `#' @batonFrequency daily`."),
      call = NULL
    )
  }

  # Get pipe names from the function name
  # It'll be NULL if it's not a function or an assignment, in this case,
  # use the script_path and the line number
  pipe_names <- purrr::map(tag_list, ~{
    is_func <- "function" %in% class(.x$object)
    if (!is_func) {
      topic <- paste0(basename(.x$file), "-", .x$line)
    } else {
      topic <- .x$object$topic
    }
    list(
      pipe_name = topic,
      is_func = is_func
    )
  })

  # Create table entries
  table_entities <- purrr::map2(pipe_names, baton_tag_vals, ~{
    tibble::tibble(
      script_path = script_path,
      pipe_name = .x$pipe_name,
      is_func = .x$is_func,
      !!!.y
    )
  }) |>
    purrr::list_rbind()

  # Check that non function pipes have only one set of tags per script
  if (any(!table_entities$is_func)) {
    multi_tag_non_func <- table_entities |>
      dplyr::filter(!is_func) |>
      dplyr::filter(dplyr::n() > 1, .by = script_path)

    if (nrow(multi_tag_non_func) > 0) {

      offending_scripts <- basename(unique(multi_tag_non_func$script_path))
      cli::cli_abort(
        c("Multiple pipelines in a single script must use functions.",
          "i" = "{offending_scripts} uses multiple sets of tags but are not
          attached to functions.",
          "i" = "Either make each pipeline a function or separate into different
          files."
        )
      )
    }
  }

  table_entities
}
