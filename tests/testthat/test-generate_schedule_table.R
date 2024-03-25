test_that("generate_schedule_table works on a directory of all good pipelines", {
  res <- generate_schedule_table(test_path("test_pipelines_all_good"))
  expect_s3_class(res, "tbl_df")
  expect_gte(nrow(res), 1)
  expect_in(
    c("script_path", "func_name", "frequency", "interval",
      "start_time", "tz"),
    names(res)
  )
}) |>
  suppressMessages()

test_that("generate_schedule_table works on a directory of some good pipelines, warns", {

  expect_warning({
    res <- generate_schedule_table(test_path("test_pipelines_some_good"))
  }, regexp = "failed to parse")

  expect_s3_class(res, "tbl_df")
  expect_gte(nrow(res), 1)
  expect_in(
    c("script_path", "func_name", "frequency", "interval",
      "start_time", "tz"),
    names(res)
  )
}) |>
  suppressMessages()

test_that("generate_schedule_table errors on a directory of all bad pipelines", {
  expect_error({
    res <- generate_schedule_table(test_path("test_pipelines_all_bad"))
  }, regexp = "All pipelines failed to parse")
}) |>
  suppressMessages()

test_that("generate_schedule_table errors on a nonexistent directory with no .R scripts", {
  expect_error({
    generate_schedule_table(test_path("directory_that_doesnt_exist"))
  }, regexp = "No directory called")
})
