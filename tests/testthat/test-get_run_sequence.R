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

  run_seq <- get_run_sequence(schedule, n = 10, include_only_primary = TRUE)
  expect_true(all(run_seq$pipe_name == "p1"))
  expect_equal(nrow(run_seq), 10L)
  expect_s3_class(run_seq$scheduled_time, "POSIXct")
  expect_true(!any(is.na(run_seq$scheduled_time)))
})
