test_that("get_artifacts returns artifacts", {
  schedule <- build_schedule(test_path("test_pipelines_run_artifacts"))

  output <- run_schedule(
    schedule,
    run_all = TRUE
  )

  artifacts <- get_artifacts(output)

  expect_type(artifacts, "list")
  expect_gt(length(artifacts), 0)
}) |>
  suppressMessages()

test_that("errors if schedule is not a MaestroSchedule", {
  expect_error({
    get_artifacts(iris)
  }, regexp = "Schedule must be an object")
})
