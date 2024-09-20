#' Checks the validity of DAG components of a schedule
#'
#' @param schedule a schedule table returned from `build_schedule`
#'
#' @return invisible or error
dag_validity_check <- function(schedule) {

  # Avoid checks if there are no inputs
  if (!"inputs" %in% names(schedule) || all(is.na(schedule$inputs))) return(invisible())

  # Check that no inputs reference nonexistent pipelines
  all_inputs <- purrr::list_c(schedule$inputs) |>
    purrr::discard(is.na) |>
    unique()

  all_pipe_names <- schedule$pipe_name

  if (any(!all_inputs %in% all_pipe_names)) {
    missing_inputs <- all_inputs[which(!all_inputs %in% all_pipe_names)]
    cli::cli_abort(
      c("Invalid Directed Acyclic Graph detected. Input{?s} {.code {missing_inputs}} declared as `maestroInputs` but do not exist as pipelines."),
      call = rlang::caller_env()
    )
  }
}
