test_that("parse batonFrequency tag works", {
  res <- roc_proc_text(
    batonFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()
  expect_in(res$val, c("minutely", "hourly", "daily", "weekly", "monthly",
                       "quarterly", "yearly"))
})

test_that("batonFrequency default value is expected", {
  res <- roc_proc_text(
    batonFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_equal(res$val, "daily")
})

test_that("bad usage of batonFrequency warns and gives no val", {
  res <- roc_proc_text(
    batonFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_bad.R"))
  ) |>
    expect_warning(regexp = "Must be one of")

  expect_null(res$val)
})

test_that("parse batonInterval tag works", {
  res <- roc_proc_text(
    batonInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "integer")
})

test_that("batonInterval default value is returned", {
  res <- roc_proc_text(
    batonInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "integer")
})

test_that("bad usage of batonInterval warns and gives no val", {
  res <- roc_proc_text(
    batonInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_interval_bad.R"))
  ) |>
    expect_warning(regexp = "Must be a positive")

  expect_null(res$val)
})

test_that("parse batonStartTime tag works", {
  res <- roc_proc_text(
    batonStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("batonStartTime default value is returned", {
  res <- roc_proc_text(
    batonStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("integer batonStartTime fails", {
  res <- roc_proc_text(
    batonInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_int.R"))
  ) |>
    expect_warning(regexp = "Must be a timestamp")

  expect_null(res$val)
})

test_that("partial batonStartTime works", {
  res <- roc_proc_text(
    batonStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_date.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("parse batonTz tag works", {
  res <- roc_proc_text(
    batonTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("batonTz default returns value", {
  res <- roc_proc_text(
    batonStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("bad usage of batonTz warns and returns null val", {
  res <- roc_proc_text(
    batonTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_tz_bad.R"))
  ) |>
    expect_warning(regexp = "Must be a valid timezone")

  expect_null(res$val)
})
