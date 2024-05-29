test_that("build_schedule works on a directory of all good pipelines", {
  res <- build_schedule(test_path("test_pipelines_parse_all_good"))
  expect_s3_class(res, "tbl_df")
  expect_gte(nrow(res), 1)
  expect_in(
    c("script_path", "pipe_name", "frequency", "start_time", "skip", "log_level"),
    names(res)
  )
  expect_snapshot(res)
}) |>
  suppressMessages()

test_that("build_schedule works on a directory of some good pipelines, warns", {

  expect_warning({
    res <- build_schedule(test_path("test_pipelines_parse_some_good"))
  }, regexp = "failed to parse")

  expect_s3_class(res, "tbl_df")
  expect_gte(nrow(res), 1)
  expect_in(
    c("script_path", "pipe_name", "frequency", "start_time", "skip", "log_level"),
    names(res)
  )
}) |>
  suppressMessages()

test_that("build_schedule errors on a directory of all bad pipelines", {
  expect_error({
    res <- build_schedule(test_path("test_pipelines_parse_all_bad"))
  }, regexp = "All scripts failed to parse")

  errors <- last_build_errors()
  expect_type(errors, "list")
  expect_gt(length(errors), 0)
}) |>
  suppressMessages()

test_that("build_schedule errors on a nonexistent directory with no .R scripts", {
  expect_error({
    build_schedule(test_path("directory_that_doesnt_exist"))
  }, regexp = "No directory called")
})
