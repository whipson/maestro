#' cli output for generate schedule table
#'
#' @param parse_errors list of parse errors
#'
#' @return cli output
btn_cli_gen_sch_tab_stat <- function(parse_errors) {

  n_fails <- length(parse_errors)

  if (n_fails == 0) {
    return(invisible())
  }

  cli::cli_alert_warning("{n_fails} pipeline(s) failed to parse:")

  # Print the name and error message
  if (n_fails <= 3) {
    purrr::iwalk(parse_errors[1:min(n_fails, 3)], ~{
      cli::cli_li(.y)
      cli::cli_text(cli::col_yellow(.x$message))
    })
    # Print just the name
  } else {
    purrr::iwalk(parse_errors[1:min(n_fails, 6)], ~{
      cli::cli_li(cli::col_yellow(.y))
    })
  }

  if(n_fails > 6) {
    n_additional <- n_fails - 6
    cli::cli_text("{n_additional} additional parsing error(s)")
  }

  cli::cli_alert_info("See full error output with {.fn latest_parsing_errors}")
  cli::cli_end()

  return(invisible())
}
