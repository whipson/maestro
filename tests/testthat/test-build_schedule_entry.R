test_that("can create a schedule entry from a single well-documented fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_in(
    c("script_path", "pipe_name", "frequency", "interval",
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
    expect_error(regexp = "Invalid maestroFrequency")
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
    expect_error(regexp = "tags present in")
}) |>
  suppressMessages()

test_that("Errors on pipeline that doesn't use functions and returns null", {

  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/tagged_but_no_func.R")
    )
  }, regexp = "has tags but no function")
}) |>
  suppressMessages()

test_that("Errors on pipeline with isolated tags", {
  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/tagged_but_no_func_multi.R")
    )
  }, regexp = "has tags but no function")
})
