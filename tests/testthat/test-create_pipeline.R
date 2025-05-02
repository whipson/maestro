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

  withr::with_tempdir({
    create_pipeline("new-pipe", start_time = "10:00:00", open = FALSE)

    expect_no_error({
      schedule <- build_schedule()

      run_schedule(schedule)
    })

    expect_true(file.exists("pipelines/new_pipe.R"))
  }) |>
    expect_message()
}) |>
  suppressMessages()

test_that("create_pipeline aborts if pipeline already exists", {

  withr::with_tempdir({
    expect_error({
      create_pipeline("new-pipe", pipeline_dir = ".", open = FALSE)
      create_pipeline("new-pipe", pipeline_dir = ".", open = FALSE)
    }, regexp = "already exists")

    # Works if overwrite = TRUE
    expect_message(
      create_pipeline("new-pipe", pipeline_dir = ".", open = FALSE, overwrite = TRUE),
      regexp = "Overwriting existing"
    )
  })
}) |>
  suppressMessages()

test_that("create_pipeline with priority", {
  withr::with_tempdir({
    create_pipeline("new-pipe", start_time = "10:00:00", open = FALSE, priority = 1, quiet = TRUE)

    expect_no_error({
      schedule <- build_schedule(quiet = TRUE)

      run_schedule(schedule, quiet = TRUE)
    })

    expect_true(file.exists("pipelines/new_pipe.R"))
  })
})
