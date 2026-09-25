test_that("Multicore works", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(
    test_path("test_pipelines_run_all_good"),
    cores = 2
  )

  expect_no_error({

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
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_fan_out"))
  run_schedule(
    schedule,
    cores = 2L
  )
  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$add_2)), c(5, 8, 11))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})

test_that("Simple collect from distinct upstreams", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_fan_in"))
  run_schedule(
    schedule,
    cores = 2
  )

  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$ab)), "ab")
})

test_that("Collect pipeline with its own downstream output runs the downstream (multicore)", {

  # Gap #6: run_pending_collects fires the collect pipe on the main process
  # after worker sync, but doesn't recurse into the collect pipe's own outputs.
  # This test will fail until that recursion is implemented.
  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_fan_in_chained"))
  run_schedule(schedule, cores = 2)

  status <- get_status(schedule)
  expect_true(all(status$invoked))
  expect_true(all(status$success))
  expect_equal(get_artifacts(schedule)$ab_upper, "AB")
})

test_that("Dynamic fan out followed by fan in", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_fan_out_collect"))
  run_schedule(
    schedule,
    cores = 2L
  )
  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$add)), 18)
})

test_that("Collect pipeline with its own downstream output runs the downstream", {

  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_fan_in_chained"))
  run_schedule(schedule, cores = 2L)

  status <- get_status(schedule)
  expect_true(all(status$invoked))
  expect_true(all(status$success))
  expect_equal(get_artifacts(schedule)$ab_upper, "AB")
})

test_that("An incidental orchestrator-level warning during a multicore run doesn't discard merged results", {

  # Regression test: MaestroSchedule$run() used to wrap its whole body in a
  # single tryCatch(warning = ...), so *any* warning surfacing while
  # collecting future results (e.g. future's own RNG-misuse check below)
  # unwound the stack before update_pipelines() could merge worker results
  # back into the main process, silently discarding an otherwise successful
  # multicore run. See R/MaestroSchedule.R.
  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  withr::local_options(future.rng.onMisuse = "warning")
  future::plan(future::multisession(workers = 2))
  withr::defer(future::plan(future::sequential))

  schedule <- build_schedule(test_path("test_pipelines_run_rng_warning"))

  expect_message({
    run_schedule(schedule, cores = 2, run_all = TRUE)
  })

  status <- get_status(schedule)
  expect_true(all(status$invoked))
  expect_true(all(status$success))

  metrics <- get_metrics(schedule)
  expect_equal(nrow(metrics), 1)
  expect_equal(metrics$metric, "draw")
}) |>
  suppressMessages()
