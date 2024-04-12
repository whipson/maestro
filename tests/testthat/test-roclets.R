test_that("parse batonFrequency tag works", {
  res <- roc_proc_text(
    batonFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()
  expect_in(res$val, c("minute", "hour", "day", "week", "month",
                       "quarter", "year"))
})

test_that("batonFrequency default value is expected", {
  res <- roc_proc_text(
    batonFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_equal(res$val, "day")
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

test_that("parse batonSkip works", {
  res <- roc_proc_text(
    batonSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_skip.R"))
  )
  expect_true(res$val)
})

test_that("Nonexistent batonSkip is NULL", {
  res <- roc_proc_text(
    batonSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  )
  expect_null(res$val)
})

test_that("Invalid usage of batonSkip warns but still returns a value of TRUE", {

  expect_warning({
    res <- roc_proc_text(
      batonSkip_roclet(),
      readLines(test_path("test_pipelines/test_pipeline_skip_bad.R"))
    )
  })

  expect_true(res$val)
})
