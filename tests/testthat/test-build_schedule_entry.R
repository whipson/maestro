test_that("can create a schedule entry from a single well-documented fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_in(
    c("script_path", "pipe_name", "is_func", "frequency", "interval",
      "start_time", "tz", "skip"),
    names(res)
  )
  expect_snapshot(res)
}) |>
  suppressMessages()

test_that("can create a schedule entry from a default tagged fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_default.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
})

test_that("invalid tags trigger error", {
  build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_bad.R")
  ) |>
    expect_error(regexp = "Invalid batonFrequency")
}) |>
  suppressMessages()

test_that("can create a schedule entry from a multi-function script", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_multi_fun_pipeline.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2)
}) |>
  suppressMessages()

test_that("Errors on a pipeline with no tagged functions", {
  build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/test_pipeline_no_func.R")
  ) |>
    expect_error(regexp = "No functions with baton")
}) |>
  suppressMessages()

test_that("Works on pipeline that doesn't use functions", {
  res <- build_schedule_entry(
    test_path("test_pipelines_parse_all_good/tagged_but_no_func.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
}) |>
  suppressMessages()
