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
