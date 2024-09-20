test_that("build_schedule works on a directory of all good pipelines", {
  res <- build_schedule(test_path("test_pipelines_parse_all_good"))
  expect_s3_class(res, "MaestroSchedule")
  schedule <- res$get_schedule()
  expect_s3_class(schedule, "data.frame")
}) |>
  suppressMessages()

test_that("build_schedule works on a directory of some good pipelines, warns", {

  expect_warning({
    res <- build_schedule(test_path("test_pipelines_parse_some_good"))
  }, regexp = "failed to parse")

  expect_s3_class(res, "MaestroSchedule")
  expect_gte(length(res$PipelineList), 1)
}) |>
  suppressMessages()

test_that("build_schedule errors on a directory of all bad pipelines", {
  expect_error({
    res <- build_schedule(test_path("test_pipelines_parse_all_bad"))
  }, regexp = "All scripts failed to parse")

  errors <- last_build_errors()
  expect_type(errors, "list")
  expect_gt(length(errors), 0)
}) |>
  suppressMessages()

test_that("build_schedule errors on a nonexistent directory with no .R scripts", {
  expect_error({
    build_schedule(test_path("directory_that_doesnt_exist"))
  }, regexp = "No directory called")
})

test_that("informs if referencing a folder with no R scripts", {
  withr::with_tempdir({
    expect_message({
      build_schedule(tempdir())
    }, regexp = "No R scripts in")
  })
})

test_that("errors if there are duplicate pipeline names", {
  expect_error({
    build_schedule(test_path("test_pipelines_dup_names"), quiet = TRUE)
  }, "Function names must all be unique")
})
