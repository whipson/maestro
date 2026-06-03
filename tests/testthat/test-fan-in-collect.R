test_that("maestroInputs parser: collect() -> is_collect TRUE, correct names", {
  tag <- roxygen2::roxy_tag("maestroInputs", "collect(src_a, src_b)", NULL)
  parsed <- roxy_tag_parse.roxy_tag_maestroInputs(tag)
  expect_equal(parsed$val$inputs, c("src_a", "src_b"))
  expect_false(parsed$val$is_each)
  expect_true(parsed$val$is_collect)
})

test_that("Simple collect from distinct upstreams", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      letter_b <- function() {
        'b'
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$ab)), "ab")
})

test_that("Simple collect from distinct upstreams - single error case", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      letter_b <- function() {
        stop()
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_equal(status$invoked, c(TRUE, TRUE, FALSE))
})

test_that("Simple collect from distinct upstreams - multi-output from upstream", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      letter_b <- function() {
        list(
          letter = 'b',
          another_var = 1:4
        )
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b$letter, .input$letter_b$another_var)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_all_equal(status$invoked, TRUE)
  expect_all_equal(status$success, TRUE)
  expect_equal(get_artifacts(schedule)$ab, c("ab1", "ab2", "ab3", "ab4"))
})

test_that("Simple collect from distinct upstreams with conditional on the collect", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      letter_b <- function() {
        'b'
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      #' @maestroRunIf .input$letter_a == 'a' && .input$letter_b == 'b'
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_all_equal(status$invoked, TRUE)
  expect_all_equal(status$success, TRUE)

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      letter_b <- function() {
        'b'
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      #' @maestroRunIf .input$letter_a == 'a' && .input$letter_b == 'c'
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_equal(status$invoked, c(TRUE, TRUE, FALSE))
})

test_that("Complex collect from distinct upstreams where an upstream is triggered twice", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      start <- function() {
        'a'
      }

      #' @maestroInputs start
      mid1 <- function(.input) {
        paste0(.input, 'b')
      }

      #' @maestroInputs start
      mid2 <- function(.input) {
        paste0(.input, 'c')
      }

      #' @maestroInputs mid1 mid2
      end <- function(.input) {
        paste0(.input, 'd')
      }

      #' @maestroInputs collect(mid2, end)
      collector <- function(.input) {
        paste0(.input$mid2, .input$end)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
  })

  status <- get_status(schedule)
  expect_length(status$pipe_name[status$pipe_name == "collector"], 1)
})


test_that("Dynamic fan out followed by fan in", {

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
      
      #' @maestroInputs collect(multiply)
      add <- function(.input) {
        sum(unlist(.input))
      }
      ",
      con = "pipelines/fanout-fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
  })
  status <- get_status(schedule)
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$add)), 18)
})

test_that("Dynamic fan out followed by fan in - partial error case", {

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
        if (.input == 2) stop()
        .input * 3
      }
      
      #' @maestroInputs collect(multiply)
      add <- function(.input) {
        sum(unlist(.input))
      }
      ",
      con = "pipelines/fanout-fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
  })
  status <- get_status(schedule)
  # multiply runs 3 times (1 error on input=2, 2 successes); add proceeds with the successful results
  expect_true(status$invoked[status$pipe_name == "add"])
  expect_true(status$success[status$pipe_name == "add"])
  # 1*3 + 3*3 = 3 + 9 = 12
  expect_equal(unlist(unname(get_artifacts(schedule)$add)), 12)
})

test_that("Dynamic fan out followed by fan in - all error case", {

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
        stop()
      }
      
      #' @maestroInputs collect(multiply)
      add <- function(.input) {
        sum(unlist(.input))
      }
      ",
      con = "pipelines/fanout-fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule, orch_frequency = "1 day"
    )
  })
  status <- get_status(schedule)
  expect_false(status$invoked[status$pipe_name == "add"])
})