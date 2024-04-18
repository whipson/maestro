test_that("parse maestroFrequency tag works", {
  res <- roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()
  expect_in(res$val, c("minute", "hour", "day", "week", "month",
                       "quarter", "year"))
})

test_that("maestroFrequency default value is expected", {
  res <- roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_equal(res$val, "day")
})

test_that("bad usage of maestroFrequency warns and gives no val", {
  res <- roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_bad.R"))
  ) |>
    expect_warning(regexp = "Must be one of")

  expect_null(res$val)
})

test_that("parse maestroInterval tag works", {
  res <- roc_proc_text(
    maestroInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "integer")
})

test_that("maestroInterval default value is returned", {
  res <- roc_proc_text(
    maestroInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "integer")
})

test_that("bad usage of maestroInterval warns and gives no val", {
  res <- roc_proc_text(
    maestroInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_interval_bad.R"))
  ) |>
    expect_warning(regexp = "Must be a positive")

  expect_null(res$val)
})

test_that("parse maestroStartTime tag works", {
  res <- roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("maestroStartTime default value is returned", {
  res <- roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("integer maestroStartTime fails", {
  res <- roc_proc_text(
    maestroInterval_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_int.R"))
  ) |>
    expect_warning(regexp = "Must be a timestamp")

  expect_null(res$val)
})

test_that("partial maestroStartTime works", {
  res <- roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_date.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("parse maestroTz tag works", {
  res <- roc_proc_text(
    maestroTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("maestroTz default returns value", {
  res <- roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("bad usage of maestroTz warns and returns null val", {
  res <- roc_proc_text(
    maestroTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_tz_bad.R"))
  ) |>
    expect_warning(regexp = "Must be a valid timezone")

  expect_null(res$val)
})

test_that("parse maestroSkip works", {
  res <- roc_proc_text(
    maestroSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_skip.R"))
  )
  expect_true(res$val)
})

test_that("Nonexistent maestroSkip is NULL", {
  res <- roc_proc_text(
    maestroSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  )
  expect_null(res$val)
})

test_that("Invalid usage of maestroSkip warns but still returns a value of TRUE", {

  expect_warning({
    res <- roc_proc_text(
      maestroSkip_roclet(),
      readLines(test_path("test_pipelines/test_pipeline_skip_bad.R"))
    )
  })

  expect_true(res$val)
})
