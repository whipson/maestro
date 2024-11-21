test_that("DAGs work as expected", {
  dag <- build_schedule(test_path("test_pipelines_dags_good"))
  run_schedule(dag)
  artifacts <- dag$get_artifacts()
  expect_true(all(dag$get_status()$success))
  expect_snapshot(dag$get_network())
  expect_equal(artifacts$with_inputs, "input message is: hello")
  expect_equal(artifacts$branch2, 2)
  expect_equal(artifacts$subbranch1, 2)
  expect_equal(artifacts$subbranch2, 6)
}) |>
  suppressMessages()

test_that("Error messages for DAGs with nonexistent inputs/outputs", {
  expect_error({
    dag_bad <- build_schedule(test_path("test_pipelines_dags_bad"))
  }, regexp = "Pipeline")
})

test_that("Error in a DAG pipeline stops downstream computations", {
  dag_bad <- build_schedule(test_path("test_pipelines_dags_run_bad"))
  run_schedule(dag_bad)
  status <- get_status(dag_bad)
  expect_true(status$invoked[status$pipe_name == "get_num"])
  expect_true(!status$invoked[status$pipe_name == "multiply"])
}) |>
  suppressMessages()

test_that("Providing just maestroInput or just maestroOutput works fine", {

  # Full redundancy - all inputs and outputs defined
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs high_road low_road
      start <- function() {
        c('a', 'A')
      }

      #' @maestroInputs start
      high_road <- function(.input) {
        toupper(.input)
      }

      #' @maestroInputs start
      low_road <- function(.input) {
        tolower(.input)
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    network_red <- schedule$get_network()
    run_schedule(schedule)
    status_red <- get_status(schedule)

    # Just outputs
    unlink("pipelines/dags.R")
    writeLines(
      "
      #' @maestroOutputs high_road low_road
      start <- function() {
        c('a', 'A')
      }

      #' @maestroFrequency 1 day
      high_road <- function(.input) {
        toupper(.input)
      }

      #' @maestroFrequency 1 day
      low_road <- function(.input) {
        tolower(.input)
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    network_jo <- schedule$get_network()
    run_schedule(schedule)
    status_jo <- get_status(schedule)

    # Just inputs
    unlink("pipelines/dags.R")
    writeLines(
      "
      #' @maestroFrequency 1 day
      start <- function() {
        c('a', 'A')
      }

      #' @maestroInputs start
      high_road <- function(.input) {
        toupper(.input)
      }

      #' @maestroInputs start
      low_road <- function(.input) {
        tolower(.input)
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    network_ji <- schedule$get_network()
    run_schedule(schedule)
    status_ji <- get_status(schedule)

    expect_equal(network_red, network_jo)
    expect_equal(network_jo, network_ji)
    expect_equal(status_red$invoked, status_jo$invoked)
    expect_equal(status_jo$invoked, status_ji$invoked)
  })
}) |>
  suppressMessages()

test_that("Resources are passed correctly for pipes with inputs", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs end
      start <- function(start_val) {
        start_val
      }

      #' @maestro
      end <- function(.input, val) {
        .input * val
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      resources = list(
        start_val = 2,
        val = 4
      )
    )
    out <- get_artifacts(schedule)
    expect_equal(out$end, 2 * 4)
  })
}) |>
  suppressMessages()

test_that("DAG with a loop fails validation", {

  # Loop with no primary
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "#' @maestroOutputs loopy2
      loopy1 <- function(.input = 1) {
        .input * 2
      }

      #' @maestroOutputs loopy3
      loopy2 <- function(.input = 1) {
        .input * 3
      }

      #' @maestroOutputs loopy1
      loopy3 <- function(.input = 1) {
        .input * 4
      }",
      con = "pipelines/dags.R"
    )

    expect_error({
      schedule <- build_schedule()
    }, regexp = "Invalid DAG")
  })

  # Primary followed by loop
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "#' @maestroOutputs loopy2
      loopy1 <- function(.input = 1) {
        .input * 2
      }

      #' @maestroOutputs loopy3
      loopy2 <- function(.input = 1) {
        .input * 3
      }

      #' @maestroOutputs loopy2
      loopy3 <- function(.input = 1) {
        .input * 4
      }",
      con = "pipelines/dags.R"
    )

    expect_error({
      schedule <- build_schedule()
    }, regexp = "Invalid DAG")
  })
})
