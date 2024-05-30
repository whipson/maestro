test_that("parse maestroFrequency tag works", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()
  expect_type(res$val, "character")
})

test_that("maestroFrequency default value is expected", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_equal(res$val, "1 day")
})

test_that("bad usage of maestroFrequency warns and gives no val", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_bad.R"))
  ) |>
    expect_warning(regexp = "Must have a format")

  expect_null(res$val)
})

test_that("parse maestroStartTime tag works", {
  res <- roxygen2::roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("maestroStartTime default value is returned", {
  res <- roxygen2::roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("integer maestroStartTime fails", {
  res <- roxygen2::roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_int.R"))
  ) |>
    expect_warning(regexp = "Must be a timestamp")

  expect_null(res$val)
})

test_that("partial maestroStartTime works", {
  res <- roxygen2::roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_start_time_date.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
  expect_s3_class(as.POSIXct(res$val), "POSIXct")
})

test_that("parse maestroTz tag works", {
  res <- roxygen2::roc_proc_text(
    maestroTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("maestroTz default returns value", {
  res <- roxygen2::roc_proc_text(
    maestroStartTime_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_default.R"))
  ) |>
    expect_no_message()

  expect_type(res$val, "character")
})

test_that("bad usage of maestroTz warns and returns null val", {
  res <- roxygen2::roc_proc_text(
    maestroTz_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_tz_bad.R"))
  ) |>
    expect_warning(regexp = "Must be a valid timezone")

  expect_null(res$val)
})

test_that("parse maestroSkip works", {
  res <- roxygen2::roc_proc_text(
    maestroSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_skip.R"))
  )
  expect_true(res$val)
})

test_that("Nonexistent maestroSkip is NULL", {
  res <- roxygen2::roc_proc_text(
    maestroSkip_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  )
  expect_null(res$val)
})

test_that("Invalid usage of maestroSkip warns but still returns a value of TRUE", {

  expect_warning({
    res <- roxygen2::roc_proc_text(
      maestroSkip_roclet(),
      readLines(test_path("test_pipelines/test_pipeline_skip_bad.R"))
    )
  })

  expect_true(res$val)
})

test_that("parse maestroLogLevel works", {
  res <- roxygen2::roc_proc_text(
    maestroLogLevel_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_loglevel_good.R"))
  )

  expect_type(res$val, "character")
})

test_that("invalid maestroLogLevel warns", {
  res <- roxygen2::roc_proc_text(
    maestroLogLevel_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_loglevel_bad.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})
