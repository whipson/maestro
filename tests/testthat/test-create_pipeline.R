test_that("create_pipeline creates a new pipeline", {
  withr::with_tempdir({
    create_pipeline("new_pipe", open = FALSE)

    expect_no_error({
      schedule <- build_schedule()

      run_schedule(schedule)
    })

    expect_true(file.exists("pipelines/new_pipe.R"))
  }) |>
    expect_message()
}) |>
  suppressMessages()

test_that("create_pipeline fixes bad names", {
  withr::with_tempdir({
    create_pipeline("new-pipe", open = FALSE)

    expect_no_error({
      schedule <- build_schedule()

      run_schedule(schedule)
    })

    expect_true(file.exists("pipelines/new_pipe.R"))
  }) |>
    expect_message()
}) |>
  suppressMessages()

test_that("create_pipeline with POSIXct works and can be run", {

  withr::with_tempdir({
    create_pipeline("new-pipe", start_time = as.POSIXct("2024-05-01 12:00:00"), open = FALSE)

    expect_no_error({
      schedule <- build_schedule()

      run_schedule(schedule)
    })

    expect_true(file.exists("pipelines/new_pipe.R"))
  }) |>
    expect_message()
}) |>
  suppressMessages()
