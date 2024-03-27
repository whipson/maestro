test_that("run_schedule works", {

  schedule <- build_schedule(test_path("test_pipelines_all_good"))

  expect_message({
    run_schedule(schedule)
  })
}) |>
  suppressMessages()

test_that("run_schedule works even with nonexistent pipeline", {

  schedule <- build_schedule(test_path("test_pipelines_all_good"))

  schedule_with_missing <- schedule |>
    add_row(
      script_path = "nonexistent",
      pipe_name = "im_a_problem",
      is_func = TRUE,
      frequency = "daily",
      interval = 1,
      start_time = as.POSIXct("1970-01-01 00:00:00")
    )

  run_schedule(schedule_with_missing) |>
    expect_message()
}) |>
  suppressMessages()
