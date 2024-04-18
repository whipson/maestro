test_that("run_schedule works", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_message({
    run_schedule(schedule, run_all = TRUE)
  })
}) |>
  suppressMessages()

test_that("run_schedule works even with nonexistent pipeline", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  schedule_with_missing <- schedule |>
    add_row(
      script_path = "nonexistent",
      pipe_name = "im_a_problem",
      is_func = TRUE,
      frequency = "day",
      interval = 1,
      start_time = as.POSIXct("1970-01-01 00:00:00")
    )

  run_schedule(schedule_with_missing, run_all = TRUE) |>
    expect_message()
}) |>
  suppressMessages()

test_that("run_schedule propagates warnings", {

  schedule <- build_schedule(test_path("test_pipelines_run_two_warnings"))

  expect_message({
    run_schedule(schedule, run_all = TRUE)
  })
}) |>
  suppressMessages()

test_that("run_schedule handles errors in a pipeline", {

  schedule <- build_schedule(test_path("test_pipelines_run_some_errors"))

  expect_message({
    run_schedule(schedule, run_all = TRUE)
  })

  errors <- latest_runtime_errors()
  expect_type(errors, "list")
  expect_length(errors, 1)
}) |>
  suppressMessages()

test_that("run_schedule checks schedule validity in the event of orchestration error", {

  # Not a data.frame
  not_a_schd <- "I'm a string"
  expect_error(
    run_schedule(not_a_schd, run_all = TRUE),
    regexp = "Schedule must be a data.frame"
  )

  # Empty data.frame
  bad_schedule <- data.frame()
  expect_error(
    run_schedule(bad_schedule, run_all = TRUE),
    regexp = "Empty schedule"
  )

  # Nonexistent required columns
  expect_error(
    run_schedule(iris, run_all = TRUE),
    regexp = "Schedule is missing required columns"
  )

  # Has required columns, but types are wrong
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))
  schedule$is_func <- "a"
  expect_error(
    run_schedule(schedule, run_all = TRUE),
    "Schedule column"
  )
}) |>
  suppressMessages()
