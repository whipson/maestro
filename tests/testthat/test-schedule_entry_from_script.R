test_that("can create a schedule entry from a single well-documented fun", {
  res <- schedule_entry_from_script(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_true(
    all(
      c("script_path", "func_name", "frequency", "interval",
        "start_time", "tz") %in% names(res)
    )
  )
})

test_that("can create a schedule entry from a default tagged fun", {
  res <- schedule_entry_from_script(
    test_path("test_pipelines/test_pipeline_daily_default.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_true(
    all(
      c("script_path", "func_name", "frequency", "interval",
        "start_time", "tz") %in% names(res)
    )
  )
})

test_that("invalid tags trigger error", {
  schedule_entry_from_script(
    test_path("test_pipelines/test_pipeline_daily_bad.R")
  ) |>
    expect_error(regexp = "Invalid batonFrequency")
})

test_that("can create a schedule entry from a multi-function script", {
  res <- schedule_entry_from_script(
    test_path("test_pipelines/test_multi_fun_pipeline.R")
  )
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 2)
  expect_true(
    all(
      c("script_path", "func_name", "frequency", "interval",
        "start_time", "tz") %in% names(res)
    )
  )
})

test_that("Errors on a pipeline with no tagged functions", {
  schedule_entry_from_script(
    test_path("test_pipelines_all_bad/test_pipeline_no_func.R")
  ) |>
    expect_error(regexp = "No functions with baton")
})
