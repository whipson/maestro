test_that("Conditional pipes work with DAG pipelines via .input", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroOutputs p2
      p1 <- function() {
        TRUE
      }

      #' @maestroRunIf .input
      p2 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = FALSE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroOutputs p2
      p1 <- function() {
        FALSE
      }

      #' @maestroRunIf .input
      p2 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)

  # More complex multiline eval
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroOutputs p2
      p1 <- function() {
        7
      }

      #' @maestroRunIf
      #' is_mod <- (.input %% 2) == 0
      #' (is_mod * 4) == 4
      p2 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)
})

test_that("DAGs with a conditional pipe in the middle by default halt further execution of the DAG", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroOutputs p2
      p1 <- function() {
        FALSE
      }

      #' @maestroRunIf .input
      p2 <- function() {
        TRUE
      }

      #' @maestroInputs p2
      p3 <- function(.input) {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)
})

test_that("Conditional pipes work using resources", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroRunIf var == 4
      p1 <- function() {
        TRUE
      }

      #' @maestroFrequency 1 day
      #' @maestroRunIf var == 3
      p2 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE,
      resources = list(var = 4)
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)
})

test_that("Conditions with errors are handled", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroRunIf stop('oh no')
      p1 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$success)
  expect_snapshot(status$invoked)
  expect_snapshot(last_run_errors())
})

test_that("Conditions that don't return a single boolean are handled", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroRunIf c(1, 2)
      p1 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = TRUE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$success)
  expect_snapshot(status$invoked)
  expect_snapshot(last_run_errors())
})

test_that("Empty maestroRunIf is ignored", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      #' @maestroRunIf
      p1 <- function() {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = FALSE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$success)
  expect_snapshot(status$invoked)
})

test_that("Branching pipelines execute with conditionals", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 day
      a <- function() {
        'b'
      }

      #' @maestroInputs a
      #' @maestroRunIf .input == 'b'
      b <- function(.input) {
        TRUE
      }

      #' @maestroInputs a
      #' @maestroRunIf .input == 'c'
      c <- function(.input) {
        TRUE
      }
      ",
      con = "pipelines/conditionals.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    run_schedule(
      schedule,
      orch_frequency = "1 day",
      quiet = FALSE
    )
    status <- get_status(schedule)
  })

  expect_snapshot(status$invoked)
})
