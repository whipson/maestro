test_that("get_flags works as expected", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      #' @maestroFlags experimental dev
      p1 <- function() {
      }

      #' @maestroFrequency 2 hours
      #' @maestroFlags critical aviation
      p2 <- function() {
      }

      #' @maestroFrequency 3 hours
      #' @maestroFlags critical
      p3 <- function() {
      }
      ",
      con = "pipelines/flags.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  flags_df <- get_flags(schedule)

  expect_snapshot(flags_df)
})

test_that("returns empty data.frame if there are no flags", {
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
      con = "pipelines/flags.R"
    )

    schedule <- build_schedule(quiet = TRUE)
  })

  flags_df <- get_flags(schedule)

  expect_snapshot(flags_df)
})
