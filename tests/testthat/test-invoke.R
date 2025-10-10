schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

test_that("invoke errors if schedule is not a MaestroSchedule", {
  expect_error({
    invoke(iris, pipe_name = "hello")
  }, regexp = "Schedule must be an object")
})

test_that("invoke errors if pipe_name is not a single character", {

  expect_error({
    invoke(schedule, pipe_name = letters)
  }, regexp = "must be a single character")
})

test_that("invoke errors if pipe_name is not in the schedule", {
  expect_error({
    invoke(schedule, pipe_name = "I don't exist")
  }, regexp = "is not the name of a pipeline in the schedule")
})

test_that("errors if resources are unnamed or non unique", {

  expect_error({
    invoke(schedule, "chatty", quiet = TRUE, resources = list(4))
  }, regexp = "All elements")

  expect_error({
    invoke(schedule, "chatty", quiet = TRUE, resources = list(a = 1, a = 2))
  }, regexp = "All elements")
})

test_that("invoke triggers the pipeline", {

  expect_no_error({
    invoke(schedule, "chatty", quiet = TRUE)
  })

  status <- schedule$get_status()
  expect_true(status$invoked[status$pipe_name == "chatty"])
})

test_that("invoke properly passes resources", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      times2 <- function(val) {
        val * 2
      }
      ",
      con = "pipelines/invoked.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    invoke(schedule, "times2", resources = list(val = 2), quiet = TRUE)

    expect_true(get_status(schedule)$success)
  })
})

test_that("invoke gives informative error message on failure", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      i_fail <- function() {
        stop()
      }
      ",
      con = "pipelines/invoked.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    invoke(schedule, "i_fail", quiet = TRUE)

    expect_snapshot(schedule$get_status()[, c("invoked", "success")])
  })
})

test_that("invoke triggers DAG pipelines", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      p1 <- function() {
        2
      }

      #' @maestroInputs p1
      p2 <- function(.input) {
        .input * 2
      }
      ",
      con = "pipelines/dag.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    invoke(schedule, "p1", quiet = TRUE)

    expect_snapshot(schedule$get_status()[, c("invoked", "success")])
  })
})

test_that("invoke only runs the pipeline selected", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency hourly
      pipe1 <- function() {
        2
      }

      #' @maestroFrequency daily
      pipe2 <- function() {
        4
      }
      ",
      con = "pipelines/invoked.R"
    )

    schedule <- build_schedule(quiet = TRUE)

    invoke(schedule, "pipe2", quiet = TRUE)

    expect_equal(sum(schedule$get_status()$invoked), 1)
  })
})