test_that("Multicore works", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_no_error({

    future::plan(future::multisession(workers = 2))

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      cores = 2,
      log_to_console = TRUE,
      run_all = TRUE
    )
  })

  status <- get_status(schedule)

  expect_snapshot(status[, c("invoked", "success")])
}) |>
  suppressMessages()

test_that("Multicore DAGs work", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  dag <- build_schedule(test_path("test_pipelines_dags_good"))
  future::plan(future::multisession(workers = 2))
  run_schedule(
    dag,
    cores = 2L
  )
  artifacts <- dag$get_artifacts()
  expect_true(all(dag$get_status()$success))
  expect_snapshot(dag$get_network())
  expect_equal(artifacts$with_inputs, "input message is: hello")
  expect_equal(artifacts$branch2, 2)
  expect_equal(artifacts$subbranch1, 2)
  expect_equal(artifacts$subbranch2, 6)
}) |>
  suppressMessages()

test_that("Simple fan out into common downstream", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      numbers <- function() {
        1:3
      }

      #' @maestroInputs each(numbers)
      multiply <- function(.input) {
        .input * 3
      }
        
      #' @maestroInputs multiply
      add_2 <- function(.input) {
        .input + 2
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      cores = 2L
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])
    expect_equal(unlist(unname(get_artifacts(schedule)$add_2)), c(5, 8, 11))
    expect_equal(length(unique(status$run_id)), length(status$run_id))
  })
})
