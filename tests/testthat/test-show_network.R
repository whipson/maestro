test_that("show_network works on all independent pipes", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)
  vis <- show_network(schedule)
  expect_s3_class(vis, "grViz")
}) |>
  suppressMessages()

test_that("show_network works on DAG pipelines", {
  schedule <- build_schedule(test_path("test_pipelines_dags_good"), quiet = TRUE)
  vis <- show_network(schedule)
  expect_s3_class(vis, "grViz")
}) |>
  suppressMessages()

test_that("errors if schedule is not a MaestroSchedule", {
  expect_error({
    show_network(iris)
  }, regexp = "Schedule must be an object")
})
