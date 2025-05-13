test_that("parse maestroFrequency tag works with '1 day'", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_good.R"))
  ) |>
    expect_no_message()
  expect_type(res$val, "character")
})

test_that("parse maestroFrequency tag works with 'daily'", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_single_good.R"))
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

test_that("bad usage of maestroFrequency warns and gives no val", {
  res <- roxygen2::roc_proc_text(
    maestroFrequency_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_daily_single_bad.R"))
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

test_that("parse maestroHours works", {
  res <- roxygen2::roc_proc_text(
    maestroHours_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_hours_good.R"))
  )

  expect_type(res$val, "double")
})

test_that("invalid maestroHours warns", {
  res <- roxygen2::roc_proc_text(
    maestroHours_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_hours_bad.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("invalid maestroHours warns", {
  res <- roxygen2::roc_proc_text(
    maestroHours_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_hours_bad2.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("parse maestroDays works for days of month", {
  res <- roxygen2::roc_proc_text(
    maestroDays_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_days_good.R"))
  )

  expect_type(res$val, "double")
})

test_that("parse maestroDays works for days of week", {
  res <- roxygen2::roc_proc_text(
    maestroDays_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_days_good2.R"))
  )

  expect_type(res$val, "integer")
})

test_that("invalid maestroDays warns for invalid days of month", {
  res <- roxygen2::roc_proc_text(
    maestroDays_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_days_bad2.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("invalid maestroDays warns for invalid days of month", {
  res <- roxygen2::roc_proc_text(
    maestroDays_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_days_bad3.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("invalid maestroDays warns for invalid days of week", {
  res <- roxygen2::roc_proc_text(
    maestroDays_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_days_bad2.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("parse maestroMonths works", {
  res <- roxygen2::roc_proc_text(
    maestroMonths_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_months_good.R"))
  )

  expect_type(res$val, "double")
})

test_that("invalid maestroMonths warns", {
  res <- roxygen2::roc_proc_text(
    maestroMonths_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_months_bad.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("invalid maestroMonths warns", {
  res <- roxygen2::roc_proc_text(
    maestroMonths_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_months_bad2.R"))
  ) |>
    expect_warning(regexp = "Invalid")

  expect_null(res$val)
})

test_that("parse maestroInputs works", {
  res <- roxygen2::roc_proc_text(
    maestroInputs_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_inputs_good.R"))
  )

  expect_type(res$val, "character")
  expect_length(res$val, 3L)
})

test_that("parse maestroInputs warns if empty", {
  res <- roxygen2::roc_proc_text(
    maestroInputs_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_inputs_bad.R"))
  ) |>
    expect_warning()

  expect_null(res$val)
})

test_that("parse maestroOutputs works", {
  res <- roxygen2::roc_proc_text(
    maestroOutputs_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_outputs_good.R"))
  )

  expect_type(res$val, "character")
  expect_length(res$val, 3L)
})

test_that("parse maestroOutputs warns if empty", {
  res <- roxygen2::roc_proc_text(
    maestroOutputs_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_outputs_bad.R"))
  ) |>
    expect_warning()

  expect_null(res$val)
})

test_that("parse maestro works", {
  res <- roxygen2::roc_proc_text(
    maestro_roclet(),
    readLines(test_path("test_pipelines/test_pipeline_maestro.R"))
  )
  expect_true(res$val)
})

test_that("maestroStartTime formatted as HH:MM:SS is valid", {
  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 10:00:00
      hhmmss <- function() {

      }
      ",
      con = "hhmmss.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroStartTime_roclet(),
      readLines("hhmmss.R")
    )
  })

  expect_type(res$val, "character")
  time <- as.POSIXct(res$val, format = "%H:%M:%S")
  expect_s3_class(time, "POSIXct")
  expect_equal(lubridate::year(time), lubridate::year(lubridate::today()))
})

test_that("maestroPriority works", {
  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroPriority 1
      priority <- function() {

      }
      ",
      con = "priority.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroPriority_roclet(),
      readLines("priority.R")
    )
  })
  expect_equal(res$val, "1")

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroPriority
      priority <- function() {

      }
      ",
      con = "priority.R"
    )

    expect_warning({
      res <- roxygen2::roc_proc_text(
        maestroPriority_roclet(),
        readLines("priority.R")
      )
    }, regexp = "Empty maestroPriority")

    expect_null(res$val)
  })

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroPriority 1.5
      priority <- function() {

      }
      ",
      con = "priority.R"
    )

    expect_warning({
      res <- roxygen2::roc_proc_text(
        maestroPriority_roclet(),
        readLines("priority.R")
      )
    }, regexp = "Invalid maestroPriority")
  })
})

test_that("parse maestroFlags works", {

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFlags critical
      tagged <- function() {

      }
      ",
      con = "tag.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroFlags_roclet(),
      readLines("tag.R")
    )

    expect_equal(res$val, "critical")
  })

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroFlags critical awesome
      tagged <- function() {

      }
      ",
      con = "tag.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroFlags_roclet(),
      readLines("tag.R")
    )

    expect_equal(length(res$val), 2)
  })
})

test_that("parse maestroLabel works", {

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroLabel severity critical
      labelled <- function() {

      }
      ",
      con = "label.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroLabel_roclet(),
      readLines("label.R")
    )

    expect_equal(res$val[[1]], c("severity", "critical"))
  })

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroLabel a lot of labels
      labelled <- function() {

      }
      ",
      con = "label.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroLabel_roclet(),
      readLines("label.R")
    ) |>
      expect_warning()

    expect_null(res$val[[1]])
  })

  withr::with_tempdir({
    writeLines(
      "
      #' @maestroLabel severity critical
      #' @maestroLabel domain transportation
      labelled <- function() {

      }
      ",
      con = "label.R"
    )

    res <- roxygen2::roc_proc_text(
      maestroLabel_roclet(),
      readLines("label.R")
    )

    expect_equal(length(res$val), 2)
  })
})
