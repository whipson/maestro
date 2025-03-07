test_that("MaestroSchedule works", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  schedule$run(
    orch_n = 1,
    orch_unit = "day"
  )

  expect_message({
    schedule$run(
      orch_n = 1,
      orch_unit = "day",
      run_all = TRUE
    )
  })

  status <- schedule$get_status()
  expect_snapshot(schedule$get_network())

  expect_s3_class(status, "data.frame")
  expect_in(
    c("pipe_name", "script_path", "invoked", "success", "pipeline_started",
      "pipeline_ended", "errors", "warnings", "messages", "next_run"
    ),
    names(status)
  )

  artifacts <- schedule$get_artifacts()

  expect_type(
    artifacts, "list"
  )
  expect_named(
    artifacts
  )
  expect_gt(length(artifacts), 0)

  expect_s3_class(status$pipeline_started, "POSIXct")
  expect_gt(nrow(status), 0)
  expect_length(last_run_errors(), 0)
  expect_length(last_run_warnings(), 0)
}) |>
  suppressMessages()

test_that("MaestroSchedule correctly returns artifacts (i.e., pipeline returns)", {

  schedule <- build_schedule(test_path("test_pipelines_run_artifacts"))

  output <- schedule$run(
    orch_n = 1,
    orch_unit = "day",
    run_all = TRUE
  )

  artifacts <- schedule$get_artifacts()

  expect_length(artifacts, 1)
  expect_equal(artifacts[[1]], "I'm an artifact")
}) |>
  suppressMessages()

test_that("MaestroSchedule works when not running all (verification of checking)", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_message({
    schedule$run(
      orch_n = 1,
      orch_unit = "day"
    )}
  )
}) |>
  suppressMessages()

test_that("Multicore works", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_no_error({
    schedule$run(
      orch_n = 1,
      orch_unit = "day",
      cores = 2,
      run_all = TRUE
    )
  })
}) |>
  suppressMessages()

test_that("MaestroSchedule informs with an empty schedule", {
  schedule <- MaestroSchedule$new()
  expect_message({
    run_schedule(schedule)
  }, "No pipelines")
})
