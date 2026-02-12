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

test_that("Downstream skipped pipelines are respected in multicore", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs mid
      start <- function() {
        1
      }
      
      #' @maestroOutputs end
      mid <- function(.input) {
        .input + 1
      }

      #' @maestro
      end <- function(.input) {
        .input + 1
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
  })
    
  future::plan(future::multisession(workers = 2L))
  run_schedule(
    schedule,
    cores = 2L
  )
})
