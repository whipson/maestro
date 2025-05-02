test_that("run_schedule works on different kinds of frequencies", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  test_freqs <- c("14 days", "10 minutes", "25 mins", "1 week",
                  "1 quarter", "12 months", "1 years", "24 hours",
                  "31 days", "1 secs", "50 seconds", "daily", "hourly", "weekly")

  purrr::walk(test_freqs, ~{
    expect_no_error({
      run_schedule(
        schedule,
        orch_frequency = .x
      ) |>
        suppressWarnings()
    })
  })
}) |>
  suppressMessages()

test_that("run_schedule errors if check_datetime is not a timestamp", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good")) |>
    suppressMessages()

  expect_error(
    run_schedule(
      schedule,
      check_datetime = "a"
    ),
    regexp = "must be a"
  )

  # But Dates work
  expect_no_error(
    run_schedule(
      schedule,
      orch_frequency = "hourly",
      check_datetime = as.Date("2024-01-01")
    )
  )
}) |>
  suppressMessages()

test_that("run_schedule with quiet=TRUE prints no messages", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good")) |>
    suppressMessages()

  expect_no_message({
    run_schedule(schedule, orch_frequency = "hourly", run_all = TRUE, quiet = TRUE)
  })

  expect_type(last_run_messages(), "list")
  expect_gt(length(last_run_messages()), 0)
})

test_that("run_schedule timeliness checks - pipelines run when they're supposed to", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "15 minutes",
    check_datetime = as.POSIXct("2024-04-25 09:35:00", tz = "UTC"),
    quiet = TRUE
  )

  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "1 month",
    check_datetime = as.POSIXct("2024-04-01 00:00:00", tz = "UTC"),
    quiet = TRUE
  ) |>
    suppressWarnings()
  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "4 days",
    check_datetime = as.POSIXct("2024-04-01 00:00:00", tz = "UTC"),
    quiet = TRUE
  ) |>
    suppressWarnings()
  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "hourly",
    check_datetime = as.POSIXct("2024-03-02 09:00:00", tz = "America/Halifax"),
    quiet = TRUE
  )

  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )
})

test_that("run_schedule timeliness checks - specifiers (e.g., hours, days, months)", {

  schedule <- build_schedule(test_path("test_pipelines_run_specifiers"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "hourly",
    check_datetime = as.POSIXct("2024-04-01 00:00:00", tz = "UTC"), # This is a Monday
    quiet = TRUE
  )

  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  schedule <- build_schedule(test_path("test_pipelines_run_specifiers"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "hourly",
    check_datetime = as.POSIXct("2024-05-01 00:00:00", tz = "UTC"), # This is a Monday
    quiet = TRUE
  )

  status <- output$get_status()

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )
})

test_that("run_schedule timeliness checks - specifiers on a non UTC timezone", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency hourly
      #' @maestroStartTime 2025-01-01 00:00:00
      #' @maestroHours 0 4 7 12 18
      non_utc_hours <- function() {

      }
      ",
      con = "pipelines/non_utc_hours.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-01-01 04:00:00", tz = "America/Halifax"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "non_utc_hours"])
  })
})

test_that("run_schedule timeliness checks - non UTC daylight savings ", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency daily
      #' @maestroStartTime 2025-03-07 00:00:00
      non_utc <- function() {

      }
      ",
      con = "pipelines/non_utc.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-10 00:00:00", tz = "America/Halifax"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "non_utc"])
  })

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency hourly
      #' @maestroStartTime 2025-03-07 00:00:00
      #' @maestroHours 4
      non_utc <- function() {

      }
      ",
      con = "pipelines/non_utc.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-10 04:00:00", tz = "America/Halifax"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "non_utc"])
  })

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency hourly
      #' @maestroStartTime 2025-03-07 00:00:00
      non_utc <- function() {

      }
      ",
      con = "pipelines/non_utc.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-08 04:00:00", tz = "America/Halifax"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "non_utc"])
  })

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency hourly
      #' @maestroStartTime 2025-03-07 00:00:00
      non_utc <- function() {

      }
      ",
      con = "pipelines/non_utc.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-11 00:00:00", tz = "UTC"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "non_utc"])
  })
})

test_that("works on pipeline with an old start time", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      #' @maestroStartTime 1970-01-01
      oldie <- function() {

      }
      ",
      con = "pipelines/oldie.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-11 00:00:00", tz = "UTC"),
      quiet = TRUE
    )

    status <- get_status(schedule)
    expect_true(status$invoked[status$pipe_name == "oldie"])
  })
})

test_that("run_schedule propagates warnings", {

  schedule <- build_schedule(test_path("test_pipelines_run_two_warnings"))

  expect_message({
    run_schedule(schedule, run_all = TRUE)
  })
  expect_gt(length(last_run_warnings()), 0)
}) |>
  suppressMessages()

test_that("run_schedule handles errors in a pipeline", {

  schedule <- build_schedule(test_path("test_pipelines_run_some_errors"))

  withr::with_tempfile("log", {
    expect_message({
      output <- run_schedule(schedule, run_all = TRUE, log_to_file = log)
    })
    status <- output$get_status()

    log_len_t1 <- length(readLines(log))
    expect_gt(log_len_t1, 0)

    errors <- last_run_errors()
    expect_type(errors, "list")
    expect_length(errors, 1)
    expect_true(all(!is.na(status$pipeline_started)))

    # Run again to ensure log file is appended to
    run_schedule(schedule, run_all = TRUE, log_to_file = log)
    log_len_t2 <- length(readLines(log))
    expect_gt(log_len_t2, log_len_t1)
  })
}) |>
  suppressMessages()

test_that("run_schedule creates maestro.log if log_to_file is TRUE", {

  schedule <- build_schedule(test_path("test_pipelines_run_some_errors"))

  withr::with_tempdir({
    run_schedule(schedule, run_all = TRUE, log_to_file = TRUE)
    expect_true(file.exists("maestro.log"))
  })
}) |>
  suppressMessages()

test_that("run_schedule doesn't create maestro.log if log_to_file is FALSE", {

  schedule <- build_schedule(test_path("test_pipelines_run_some_errors"))

  withr::with_tempdir({
    run_schedule(schedule, run_all = TRUE, log_to_file = FALSE)
    expect_true(!file.exists("maestro.log"))
  })
}) |>
  suppressMessages()

test_that("run_schedule checks type of schedule", {
  expect_error(
    run_schedule(iris, run_all = TRUE),
    regexp = "Schedule must be an object of"
  )
}) |>
  suppressMessages()

test_that("errors on invalid orch_frequency", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  expect_error({
    run_schedule(schedule, orch_frequency = "1 potato")
  }, regexp = "Invalid `orch_frequency`")

  expect_error({
    run_schedule(schedule, orch_frequency = "56 weeks")
  }, regexp = "Invalid `orch_frequency`")
})

test_that("errors if resources are unnamed or non unique", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  expect_error({
    run_schedule(schedule, orch_frequency = "hourly", resources = list(1))
  }, regexp = "All elements")

  expect_error({
    run_schedule(schedule, orch_frequency = "hourly", resources = list(a = 1, a = 2))
  }, regexp = "All elements")
})

test_that("warns if the orch frequency is less than the highest pipe frequency", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)
  expect_warning({
    run_schedule(schedule, orch_frequency = "daily")
  })

  # Unless run_all = TRUE
  expect_no_warning({
    run_schedule(schedule, orch_frequency = "daily", run_all = TRUE)
  })
}) |>
  suppressMessages()

test_that("errors if orch_frequency is less than 1 year", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)
  expect_error({
    run_schedule(
      schedule,
      orch_frequency = "2 years"
    )
  }, regexp = "Invalid `orch_frequency`")
})

test_that("maestroStartTime with HH:MM:SS runs on the expected time", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroStartTime 10:00:00
      hhmmss <- function() {

      }
      ",
      con = "pipelines/hhmmss.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct(glue::glue("{lubridate::today()} 10:00:00"), tz = "UTC"),
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)
})

test_that("maestroPriority works as expected", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroStartTime 10:00:00
      p2 <- function() {
      }

      #' @maestroFrequency 1 day
      #' @maestroStartTime 10:00:00
      #' @maestroPriority 1
      q1 <- function() {
        Sys.sleep(1)
      }
      ",
      con = "pipelines/priorities.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2025-03-17 10:00:00", tz = "UTC"),
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$pipe_name)
})
