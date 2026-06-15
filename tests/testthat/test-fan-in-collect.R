test_that("collect() with fewer than two inputs errors at build_schedule()", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      src_a <- function() 'a'

      #' @maestroInputs collect(src_a)
      downstream <- function(.input) .input$src_a
      ",
      con = "pipelines/bad_collect.R"
    )
    expect_error(build_schedule(), regexp = "collect\\(\\).*at least two input pipelines or a single")
  })
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

test_that("Collect does not run when a non-each input errored", {

  # This tests gap #2: the non_each_pending guard uses != "Not Run", so an
  # errored input passes through and collect would run with NULL as that input.
  # A single primary fans out to two branches (so both are always visited before
  # collect is evaluated, removing any traversal-order ambiguity).
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      source <- function() {
        'a'
      }

      #' @maestroInputs source
      branch_ok <- function(.input) {
        paste0(.input, 'b')
      }

      #' @maestroInputs source
      branch_err <- function(.input) {
        stop('deliberate error')
      }

      #' @maestroInputs collect(branch_ok, branch_err)
      collector <- function(.input) {
        paste0(.input$branch_ok, .input$branch_err)
      }",
      con = "pipelines/fanin.R"
    )

    schedule <- build_schedule()
    run_schedule(schedule)
  })

  status <- get_status(schedule)
  expect_false(status$invoked[status$pipe_name == "collector"])
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


test_that("Collect pipeline with its own downstream output runs the downstream", {

  schedule <- build_schedule(test_path("test_pipelines_fan_in_chained"))
  run_schedule(schedule)

  status <- get_status(schedule)
  expect_true(all(status$invoked))
  expect_true(all(status$success))
  expect_equal(get_artifacts(schedule)$ab_upper, "AB")
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

      #' @maestroInputs numbers
      #' @maestroMap
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

      #' @maestroInputs numbers
      #' @maestroMap
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

      #' @maestroInputs numbers
      #' @maestroMap
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

test_that("Fan-out collect with iterateOver", {

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
      }
      
      #' @maestroInputs collect(make_message)
      capitalize <- function(.input) {
        paste(toupper(unlist(.input)))
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
  })
  expect_snapshot(status[, c("invoked", "success")])
  expect_equal(unlist(unname(get_artifacts(schedule)$capitalize)), paste("HELLO", c("A", "B", "C")))
})

test_that("Possibly conflicting info from maestroInputs collect and maestroOutputs", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      letter_a <- function() {
        'a'
      }

      #' @maestroFrequency daily
      #' @maestroOutputs ab
      letter_b <- function() {
        'b'
      }
        
      #' @maestroInputs collect(letter_a, letter_b)
      ab <- function(.input) {
        paste0(.input$letter_a, .input$letter_b)
      }",
      con = "pipelines/fanout.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
  })

  expect_equal(unlist(unname(get_artifacts(schedule)$ab)), "ab")
})
