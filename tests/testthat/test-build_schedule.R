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

# --- cache / from_cache tests ------------------------------------------------

test_that("cache_schedule writes an rds and build_schedule from_cache round-trips", {
  good_pipelines <- normalizePath(test_path("test_pipelines_parse_all_good"))
  withr::with_tempdir({
    schedule <- build_schedule(good_pipelines, quiet = TRUE)
    cache_schedule(schedule) |> suppressMessages()

    expect_true(file.exists(".maestro/schedule.rds"))

    cached <- build_schedule(from_cache = TRUE, quiet = TRUE)
    expect_s3_class(cached, "MaestroSchedule")
    expect_equal(
      cached$PipelineList$get_pipe_names(),
      schedule$PipelineList$get_pipe_names()
    )
  })
}) |>
  suppressMessages()

test_that("build_schedule from_cache errors when cache file does not exist", {
  withr::with_tempdir({
    expect_error(
      build_schedule(from_cache = TRUE),
      regexp = "does not exist"
    )
  })
})

test_that("build_schedule from_cache errors when rds is not a MaestroSchedule", {
  withr::with_tempdir({
    dir.create(".maestro", recursive = TRUE)
    saveRDS(list(a = 1), ".maestro/schedule.rds")
    expect_error(
      build_schedule(from_cache = TRUE),
      regexp = "MaestroSchedule"
    )
  })
})

test_that("refresh_schedule refreshes run sequences and returns schedule invisibly", {
  schedule <- build_schedule(
    test_path("test_pipelines_parse_all_good"),
    quiet = TRUE
  )
  seq_after <- schedule$PipelineList$MaestroPipelines[[1]]$get_run_sequence()

  # run sequences should be non-empty and still valid POSIXct vectors
  expect_true(length(seq_after) > 0)
  expect_s3_class(seq_after, "POSIXct")
  expect_invisible(refresh_schedule(schedule, quiet = TRUE))
}) |>
  suppressMessages()

test_that("refresh_schedule errors on non-MaestroSchedule input", {
  expect_error(
    refresh_schedule(list()),
    regexp = "MaestroSchedule"
  )
})

test_that("cache_schedule creates .maestro directory if needed", {
  good_pipelines <- normalizePath(test_path("test_pipelines_parse_all_good"))
  withr::with_tempdir({
    schedule <- build_schedule(good_pipelines, quiet = TRUE)
    cache_schedule(schedule) |> suppressMessages()
    expect_true(file.exists(".maestro/schedule.rds"))
  })
}) |>
  suppressMessages()
