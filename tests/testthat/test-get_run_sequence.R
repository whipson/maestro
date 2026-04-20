test_that("get_run_sequence works", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      p1 <- function() {
      }

      #' @maestroFrequency 2 hours
      p2 <- function() {
      }

      #' @maestroFrequency 3 hours
      p3 <- function() {
      }
      ",
      con = "pipelines/pipes.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  run_seq <- get_run_sequence(schedule, n = 10)
  expect_in(c("p1", "p2", "p3"), unique(run_seq$pipe_name))
  expect_equal(nrow(run_seq), 30L)
  expect_s3_class(run_seq$scheduled_time, "POSIXct")
  expect_true("is_primary" %in% names(run_seq))
  expect_true(all(run_seq$is_primary))
})

test_that("informative error messages on invalid params", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      p1 <- function() {
      }

      #' @maestroFrequency 2 hours
      p2 <- function() {
      }

      #' @maestroFrequency 3 hours
      p3 <- function() {
      }
      ",
      con = "pipelines/pipes.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  expect_error(
    get_run_sequence(schedule, n = -1),
    regexp = "must be a positive integer"
  )

  expect_error(
    get_run_sequence(schedule, min_datetime = 4),
    regexp = "must be a Date"
  )

  expect_error(
    get_run_sequence(schedule, min_datetime = as.Date("2025-01-01"), max_datetime = as.Date("2024-12-31")),
    regexp = "cannot be greater than"
  )

  expect_error(
    get_run_sequence(schedule, include_only_primary = "a"),
    regexp = "must be a boolean"
  )

  expect_error(
    get_run_sequence(schedule, include_skipped = "a"),
    regexp = "must be a boolean"
  )
})

test_that("dags are properly represented", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      p1 <- function() {
      }

      #' @maestroInputs p1
      p2 <- function(.input) {
      }

      #' @maestroInputs p2
      p3 <- function(.input) {
      }
      ",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  run_seq <- get_run_sequence(schedule, n = 10)
  expect_in(c("p1", "p2", "p3"), unique(run_seq$pipe_name))
  expect_equal(nrow(run_seq), 30L)
  expect_s3_class(run_seq$scheduled_time, "POSIXct")
  expect_true(!any(is.na(run_seq$scheduled_time)))

  # is_primary: p1 is root, p2 and p3 are downstream
  expect_true(all(run_seq$is_primary[run_seq$pipe_name == "p1"]))
  expect_true(all(!run_seq$is_primary[run_seq$pipe_name %in% c("p2", "p3")]))

  run_seq <- get_run_sequence(schedule, n = 10, include_only_primary = TRUE)
  expect_true(all(run_seq$pipe_name == "p1"))
  expect_equal(nrow(run_seq), 10L)
  expect_s3_class(run_seq$scheduled_time, "POSIXct")
  expect_true(!any(is.na(run_seq$scheduled_time)))
})

test_that("include_skipped = FALSE excludes skipped pipelines", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      p1 <- function() {
      }

      #' @maestroFrequency 2 hours
      #' @maestroSkip
      p2 <- function() {
      }

      #' @maestroFrequency 3 hours
      p3 <- function() {
      }
      ",
      con = "pipelines/pipes.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  run_seq_all <- get_run_sequence(schedule, n = 10, include_skipped = TRUE)
  expect_in(c("p1", "p2", "p3"), unique(run_seq_all$pipe_name))

  run_seq_no_skip <- get_run_sequence(schedule, n = 10, include_skipped = FALSE)
  expect_false("p2" %in% unique(run_seq_no_skip$pipe_name))
  expect_in(c("p1", "p3"), unique(run_seq_no_skip$pipe_name))
})

test_that("backward-looking min_datetime returns historic run sequences", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroStartTime 04:00:00
      daily_early <- function() {
      }

      #' @maestroFrequency 1 hour
      hourly <- function() {
      }
      ",
      con = "pipelines/pipes.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  now <- lubridate::now()
  min_dt <- now - lubridate::days(7)
  max_dt <- now

  run_seq <- get_run_sequence(schedule, min_datetime = min_dt, max_datetime = max_dt)

  expect_in(c("daily_early", "hourly"), unique(run_seq$pipe_name))
  expect_s3_class(run_seq$scheduled_time, "POSIXct")
  expect_true(all(run_seq$scheduled_time >= min_dt))
  expect_true(all(run_seq$scheduled_time <= max_dt))

  # daily pipeline at 04:00:00 should have ~7 occurrences over 7 days
  daily_seq <- run_seq[run_seq$pipe_name == "daily_early", ]
  expect_gte(nrow(daily_seq), 6L)
  expect_lte(nrow(daily_seq), 8L)
})