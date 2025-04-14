test_that("get_slot_usage works as expected", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      #' @maestroStartTime 10:00:00
      hourly1 <- function() {
      }

      #' @maestroFrequency 2 hours
      #' @maestroStartTime 10:00:00
      hourly2 <- function() {
      }

      #' @maestroFrequency 3 hours
      #' @maestroStartTime 10:00:00
      #' @maestroTz America/Halifax
      hourly3 <- function() {
      }
      ",
      con = "pipelines/hourlies.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  avail_hour <- get_slot_usage(
    schedule,
    orch_frequency = "1 hour"
  )
  expect_snapshot(avail_hour)

  avail_day <- get_slot_usage(
    schedule,
    orch_frequency = "1 hour",
    slot_interval = "day"
  )

  expect_snapshot(avail_day)
})

test_that("get_slot_usage works with variety of frequencies", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      #' @maestroStartTime 10:00:00
      hourly1 <- function() {
      }

      #' @maestroFrequency 3 days
      #' @maestroStartTime 2025-01-01 12:00:00
      daily1 <- function() {
      }

      #' @maestroFrequency weekly
      #' @maestroStartTime 2025-01-02 10:00:00
      #' @maestroTz UTC
      weekly1 <- function() {
      }
      ",
      con = "pipelines/multi.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  avail_hour <- get_slot_usage(
    schedule,
    orch_frequency = "1 hour"
  )
  expect_snapshot(avail_hour)

  avail_day <- get_slot_usage(
    schedule,
    orch_frequency = "1 hour",
    slot_interval = "day"
  )

  expect_snapshot(avail_day)

  avail_week <- get_slot_usage(
    schedule,
    orch_frequency = "1 hour",
    slot_interval = "week"
  )

  expect_snapshot(avail_week)
})

test_that("get_slot_usage informs on empty schedule", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "",
      con = "pipelines/multi.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  expect_message({
    get_slot_usage(
      schedule,
      "1 hour"
    )
  })
})
