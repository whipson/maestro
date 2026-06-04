test_that("Simple fan out with no specified iterator", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      numbers <- function() {
        1:3
      }

      #' @maestroInputs numbers
      #' @maestroMap
      multiply <- function(.input) {
        .input * 3
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
  })

  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$multiply)), c(3, 6, 9))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})

test_that("Simple fan out into common downstream", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      numbers <- function() {
        1:3
      }

      #' @maestroInputs numbers
      #' @maestroMap
      multiply <- function(.input) {
        .input * 3
      }
        
      #' @maestroInputs multiply
      add_2 <- function(.input) {
        .input + 2
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
  })
  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$add_2)), c(5, 8, 11))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})

test_that("Simple fan out into common downstream and one error", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      numbers <- function() {
        1:3
      }

      #' @maestroInputs numbers
      #' @maestroMap
      multiply <- function(.input) {
        if (.input == 1) stop()
        .input * 3
      }
        
      #' @maestroInputs multiply
      add_2 <- function(.input) {
        .input + 2
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
    status <- get_status(schedule)
  })
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$add_2)), c(8, 11))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})

test_that("Use iterateOver to specify a particular iteration variable", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      get_letters <- function() {
        list(
          letter = letters[1:3],
          greeting = 'hello'
        )
      }

      #' @maestroInputs get_letters
      #' @maestroMap .input$letter
      make_message <- function(.input) {
        paste(.input$greeting, toupper(.input$letter))
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
    status <- get_status(schedule)
  })
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$make_message)), paste("hello", c("A", "B", "C")))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})

test_that("Fan out where upstream returns a list of S3 objects (lm)", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      fit_models <- function() {
        list(
          lm(mpg ~ wt, data = mtcars),
          lm(mpg ~ hp, data = mtcars),
          lm(mpg ~ cyl, data = mtcars)
        )
      }

      #' @maestroInputs fit_models
      #' @maestroMap
      extract_r2 <- function(.input) {
        summary(.input)$r.squared
      }",
      con = "pipelines/fanout_lm.R"
    )

    schedule <- build_schedule()
    run_schedule(schedule, orch_frequency = "1 day")
    status <- get_status(schedule)
  })

  r2_values <- unlist(unname(get_artifacts(schedule)$extract_r2))
  expect_length(r2_values, 3)
  expect_true(all(r2_values > 0 & r2_values <= 1))
  expect_snapshot(status[, c("invoked", "success")])
})

test_that("Fan where the field contains S3 objects (lm)", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      fit_models <- function() {
        list(
          model = list(
            lm(mpg ~ wt, data = mtcars),
            lm(mpg ~ hp, data = mtcars),
            lm(mpg ~ cyl, data = mtcars)
          ),
          label = c('wt', 'hp', 'cyl')
        )
      }

      #' @maestroInputs fit_models
      #' @maestroMap .input$model
      extract_r2 <- function(.input) {
        summary(.input$model)$r.squared
      }",
      con = "pipelines/fanout_lm.R"
    )

    schedule <- build_schedule()
    run_schedule(schedule, orch_frequency = "1 day")
    status <- get_status(schedule)
  })

  r2_values <- unlist(unname(get_artifacts(schedule)$extract_r2))
  expect_length(r2_values, 3)
  expect_true(all(r2_values > 0 & r2_values <= 1))
  expect_snapshot(status[, c("invoked", "success")])
})

test_that("map is misspecified name in return", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      get_letters <- function() {
        list(
          letter = letters[1:3],
          greeting = 'hello'
        )
      }

      #' @maestroInputs get_letters
      #' @maestroMap .input$asd
      make_message <- function(.input) {
        paste(.input$greeting, toupper(.input$letter))
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
    status <- get_status(schedule)
  })
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(last_run_errors()$make_message, "Error before pipeline execution: Field(s) 'asd' specified in @maestroMap not found in the output of the upstream pipeline.")
})

test_that("iterateOver with unequal length vectors errors", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      get_data <- function() {
        list(
          ids = 1:3,
          labels = c('a', 'b')
        )
      }

      #' @maestroInputs get_data
      #' @maestroMap .input$ids .input$labels
      process <- function(.input) {
        paste(.input$ids, .input$labels)
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(schedule, orch_frequency = "1 day")
    status <- get_status(schedule)
  })
  expect_match(
    last_run_errors()$process,
    regexp = "same length or length 1"
  )
})

test_that("Use iterateOver with multiple iterators", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      get_letters <- function() {
        list(
          letter = letters[1:3],
          greeting = c('hello', 'cheers', 'hi')
        )
      }

      #' @maestroInputs get_letters
      #' @maestroMap .input$letter .input$greeting
      make_message <- function(.input) {
        paste(.input$greeting, toupper(.input$letter))
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
    status <- get_status(schedule)
  })
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$make_message)), c("hello A", "cheers B", "hi C"))
  expect_equal(length(unique(status$run_id)), length(status$run_id))
})