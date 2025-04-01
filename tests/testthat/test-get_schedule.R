test_that("get_schedule returns a data.frame", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)
  expect_s3_class(
    get_schedule(schedule),
    "data.frame"
  )

  expect_snapshot(schedule)
}) |>
  suppressMessages()

test_that("errors if schedule is not a MaestroSchedule", {
  expect_error({
    get_schedule(iris)
  }, regexp = "Schedule must be an object")
})

test_that("get_schedule works with DAG schedules", {
  schedule <- build_schedule(test_path("test_pipelines_dags_good"))
  expect_snapshot(get_schedule(schedule)[, c("script_path", "pipe_name", "frequency", "tz", "skip", "log_level")])
}) |>
  suppressMessages()
