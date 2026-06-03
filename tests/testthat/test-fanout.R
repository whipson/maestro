
test_that("maestroInputs parser: plain names -> is_each/is_collect FALSE", {
  tag <- roxygen2::roxy_tag("maestroInputs", "upstream_a upstream_b", NULL)
  parsed <- roxy_tag_parse.roxy_tag_maestroInputs(tag)
  expect_equal(parsed$val$inputs, c("upstream_a", "upstream_b"))
  expect_false(parsed$val$is_each)
  expect_false(parsed$val$is_collect)
})

test_that("maestroInputs parser: each() -> is_each TRUE, correct names", {
  tag <- roxygen2::roxy_tag("maestroInputs", "each(upstream_a)", NULL)
  parsed <- roxy_tag_parse.roxy_tag_maestroInputs(tag)
  expect_equal(parsed$val$inputs, "upstream_a")
  expect_true(parsed$val$is_each)
  expect_false(parsed$val$is_collect)
})

test_that("maestroInputs parser: each() with multiple names", {
  tag <- roxygen2::roxy_tag("maestroInputs", "each(up_a, up_b)", NULL)
  parsed <- roxy_tag_parse.roxy_tag_maestroInputs(tag)
  expect_equal(parsed$val$inputs, c("up_a", "up_b"))
  expect_true(parsed$val$is_each)
})

test_that("maestroIterateOver parser stores raw string verbatim", {
  raw <- "id = .input$ids lbl = .input$labels"
  tag <- roxygen2::roxy_tag("maestroIterateOver", raw, NULL)
  parsed <- roxy_tag_parse.roxy_tag_maestroIterateOver(tag)
  expect_equal(parsed$val, raw)
})

test_that("Simple fan out with no specified iterator", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      numbers <- function() {
        1:3
      }

      #' @maestroInputs each(numbers)
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

      #' @maestroInputs each(numbers)
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

      #' @maestroInputs each(numbers)
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

      #' @maestroInputs each(get_letters)
      #' @maestroIterateOver .input$letter
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

      #' @maestroInputs each(fit_models)
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

test_that("Fan out with iterateOver where the field contains S3 objects (lm)", {

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

      #' @maestroInputs each(fit_models)
      #' @maestroIterateOver .input$model
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

test_that("iterateOver is misspecified name in return", {

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

      #' @maestroInputs each(get_letters)
      #' @maestroIterateOver .input$asd
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
  expect_equal(last_run_errors()$make_message, "Error before pipeline execution: Field 'asd' specified in @maestroIterateOver not found in the output of the upstream pipeline.")
})
