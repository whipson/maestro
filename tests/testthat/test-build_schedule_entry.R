test_that("can create a schedule entry from a single well-documented fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_in(
    c("script_path", "pipe_name", "frequency",
      "start_time", "tz", "skip", "log_level",
      "frequency_n", "frequency_unit", "days", "days_of_week",
      "days_of_month"),
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

test_that("Informative error on parsing schedule entry with an error", {
  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/test_pipeline_script_with_error.R")
    )
  }, regexp = "Could not build")
})

test_that("Script with untagged function isn't treated as a scheduled pipeline", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_good/pipe_with_custom_fun.R")
  )
  expect_equal(nrow(schedule), 1)
})

test_that("Script with good specifiers parses well", {
  expect_no_error({
    schedule <- build_schedule_entry(
      test_path("test_pipelines_parse_all_good/specifiers.R")
    )
  })
})

test_that("Script with bad specifiers errors", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/specifiers.R")
  ) |>
    expect_error(regexp = "pipeline must have")
})
