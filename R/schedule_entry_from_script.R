#' Create schedule table entry from a script
#'
#' @param script_path path to script
#'
#' @return data.frame row
schedule_entry_from_script <- function(script_path) {

  # Current list of baton tags and their equivalent table names
  baton_tag_names <- list(
    frequency = "batonFrequency",
    interval = "batonInterval",
    start_time = "batonStartTime",
    tz = "batonTz"
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

  # Get function names
  func_names <- purrr::map_chr(tag_list, ~.x$object$topic)

  # Create table entries
  purrr::map2(func_names, baton_tag_vals, ~{
    tibble::tibble(
      script_path = script_path,
      func_name = .x,
      !!!.y
    )
  }) |>
    purrr::list_rbind()
}
