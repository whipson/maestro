#' Run a schedule
#'
#' @param schedule_table a table of scheduled pipelines generated from `build_schedule()`
#' @param resources list of shared resources made available to pipelines as needed
#'
#' @return invisible
#' @export
run_schedule <- function(schedule_table, resources = list()) {

  # Validations on schedule table

  # Function to filter which pipelines are to run (for now we run them all)

  purrr::pwalk(
    list(
      schedule_table$script_path,
      schedule_table$pipe_name,
      schedule_table$is_func
    ),
    purrr::safely(
      ~{

        # Source the script
        source(..1)

        # If it's a function
        if(..3) {

          args <- formals(..2)

          do.call(..2, args = resources[names(args)])
        }
      }
    )
  )
}
