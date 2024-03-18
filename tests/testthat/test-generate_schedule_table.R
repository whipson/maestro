test_that("generate schedule table works on a directory of all good pipelines", {
  res <- generate_schedule_table(test_path("test_pipelines_all_good"))
  expect_s3_class(res, "tbl_df")
  expect_in(
    c("script_path", "func_name", "frequency", "interval",
      "start_time", "tz"),
    names(res)
  )
})

test_that("generate schedule table works on a directory of some good pipelines, warns", {
  res <- generate_schedule_table(test_path("test_pipelines_some_good"))
  expect_s3_class(res, "tbl_df")
  expect_gte(nrow(res), 1)
  expect_in(
    c("script_path", "func_name", "frequency", "interval",
      "start_time", "tz"),
    names(res)
  )
}) |>
  suppressMessages()
