#' cli output for generate schedule table
#'
#' @param parse_succeeds list of parse results (i.e., succeeded)
#' @param parse_errors list of parse errors
#'
#' @keywords internal
#' @return cli output
maestro_parse_cli <- function(parse_succeeds, parse_errors) {

  n_fails <- length(parse_errors)
  n_succeeds <- length(parse_succeeds)

  if(n_succeeds == 0) {

    cli::cli_abort(
      c(
        "x" = "All scripts failed to parse",
        "i" = "See full error output with {.fn last_build_errors}"
      ),
      call = rlang::caller_env()
    )
  } else {

    if (n_succeeds > 0) {
      cli::cli_inform(
        c("i" = "{n_succeeds} script{?s} successfully parsed")
      )
    }

    if (n_fails > 0) {
      fail_vec <- purrr::map_chr(parse_errors, ~{
        .x$message
      }) |>
        stats::setNames("!")

      cli::cli_warn(
        c(
          "{n_fails} script{?s} failed to parse:",
          fail_vec,
          "i" = "See full error output with {.fn last_build_errors}"
        )
      )
    }
  }

  return(invisible())
}

#' cli output for dependency tree
#'
#' @param adjacency_list data.frame containing the from and to connections using the pipe_ids (a private attribute of MaestroPipeline)
#'
#' @keywords internal
#' @return cli output
maestro_dependency_graph_cli <- function(adjacency_list) {

  if (nrow(adjacency_list) == 0) return(invisible())

  names_not_in <- setdiff(unique(c(adjacency_list$from, adjacency_list$to)), adjacency_lc$from)

  childless_dat <- data.frame(
    from = names_not_in,
    to = NA_character_
  )

  adjacency_lc <- adjacency_list |>
    dplyr::bind_rows(childless_dat) |>
    dplyr::summarise(to = list(to), .by = from)

  cli::tree(
    data = adjacency_lc
  )
}
