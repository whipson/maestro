test_that("get_status returns a data.frame", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)
  schedule <- run_schedule(schedule)

  expect_s3_class(
    get_status(schedule),
    "data.frame"
  )
}) |>
  suppressMessages()

test_that("errors if schedule is not a MaestroSchedule", {
  expect_error({
    get_status(iris)
  }, regexp = "Schedule must be an object")
})
