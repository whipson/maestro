test_that("can get a single labeled pipeline", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroLabel domain transportation
      labelled <- function() {

      }
      ",
      con = "pipelines/label.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    expect_snapshot(schedule$get_labels())
  })
})

test_that("can get a double labeled pipeline", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroLabel domain transportation
      #' @maestroLabel author will
      labelled <- function() {

      }
      ",
      con = "pipelines/label.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    expect_snapshot(schedule$get_labels())
  })
})

test_that("works when there are no labeled pipelines", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      not_labeled <- function() {

      }
      ",
      con = "pipelines/label.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    expect_equal(nrow(schedule$get_labels()), 0)
  })
})

test_that("can get a double labeled pipeline with the same key", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroLabel author will
      #' @maestroLabel author kaz
      labelled <- function() {

      }
      ",
      con = "pipelines/label.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    expect_snapshot(schedule$get_labels())
  })
})