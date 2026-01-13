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

test_that("Even if a downstream pipeline is 'scheduled' it doesn't run unless the upstream component does", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 09:00:00
      #' @maestroTz UTC
      #' @maestroOutputs end
      start <- function() {
        2
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 08:00:00
      #' @maestroTz UTC
      end <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      orch_frequency = "hourly",
      check_datetime = as.POSIXct("2024-11-22 08:00:00", tz = "UTC")
    )

    expect_snapshot(schedule$get_status()$invoked)
  })

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 09:00:00
      #' @maestroTz UTC
      #' @maestroOutputs mid
      start <- function() {
        2
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 08:00:00
      #' @maestroTz UTC
      #' @maestroOutputs end
      mid <- function(.input) {
        .input / 10
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 08:00:00
      #' @maestroTz UTC
      end <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      orch_frequency = "hourly",
      check_datetime = as.POSIXct("2024-11-22 08:00:00", tz = "UTC")
    )

    expect_snapshot(schedule$get_status()$invoked)
  })
}) |>
  suppressMessages()

test_that("Even if a downstream pipeline is 'scheduled' it runs if the upstream component does", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 09:00:00
      #' @maestroTz UTC
      #' @maestroOutputs end
      start <- function() {
        2
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 10:00:00
      #' @maestroTz UTC
      end <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      orch_frequency = "hourly",
      check_datetime = as.POSIXct("2024-11-22 09:00:00", tz = "UTC")
    )

    expect_snapshot(schedule$get_status()$invoked)
  })

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 09:00:00
      #' @maestroTz UTC
      #' @maestroOutputs mid
      start <- function() {
        2
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 10:00:00
      #' @maestroTz UTC
      #' @maestroOutputs end
      mid <- function(.input) {
        .input / 10
      }

      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2024-11-22 10:00:00
      #' @maestroTz UTC
      end <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule,
      orch_frequency = "hourly",
      check_datetime = as.POSIXct("2024-11-22 09:00:00", tz = "UTC")
    )

    expect_snapshot(schedule$get_status()$invoked)
  })
}) |>
  suppressMessages()

test_that("Branching DAG pipelines with an error in one branch continue on second branch", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs mid
      start <- function() {
        4
      }

      #' @maestroOutputs end1 end2
      mid <- function(.input) {
        .input * 3
      }

      #' @maestro
      end1 <- function(.input) {
        stop()
        .input * 2
      }
        
      #' @maestro
      end2 <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])
  })
})

test_that("Branching DAG pipelines both ending in errors accurately outputs errors", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs mid
      start <- function() {
        4
      }

      #' @maestroOutputs end1 end2
      mid <- function(.input) {
        .input * 3
      }

      #' @maestro
      end1 <- function(.input) {
        stop('oops')
        .input * 2
      }
        
      #' @maestro
      end2 <- function(.input) {
        stop('oh dear')
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])
    expect_snapshot(last_run_errors())
  })
})

test_that("Branching and merging DAG pipelines have separate status entries for each lineage", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs mid1 mid2
      start <- function() {
        4
      }

      #' @maestroOutputs end
      mid1 <- function(.input) {
        .input * 3
      }

      #' @maestroOutputs end
      mid2 <- function(.input) {
        .input * 2
      }
        
      #' @maestro
      end <- function(.input) {
        .input * 2
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])
    expect_snapshot(unname(unlist(get_artifacts(schedule))))
  })
})

test_that("Branching and merging DAG pipelines use vectors for multiple errors", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroOutputs mid1 mid2
      start <- function() {
        4
      }

      #' @maestroOutputs end
      mid1 <- function(.input) {
        .input * 3
      }

      #' @maestroOutputs end
      mid2 <- function(.input) {
        .input * 2
      }
        
      #' @maestro
      end <- function(.input) {
        stop('oops')
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])
    expect_snapshot(unname(unlist(get_artifacts(schedule))))
    expect_snapshot(last_run_errors())

    lineage <- get_lineage(schedule) |> 
      dplyr::select(from_name, to_name)
    
    expect_snapshot(lineage)
  })
})

test_that("Two separate DAGs have separate lineages", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroOutputs end
      start <- function() {
        4
      }

      #' @maestro
      end <- function(.input) {
        .input * 3
      }

      #' @maestroFrequency daily
      #' @maestroPriority 1
      start2 <- function() {
        3
      }
      
      #' @maestroInputs start2
      end2 <- function(.input) {
        .input * 5
      }",
      con = "pipelines/dags.R"
    )

    schedule <- build_schedule()
    run_schedule(
      schedule
    )
    status <- get_status(schedule)
    expect_snapshot(status[, c("invoked", "success")])

    lineage <- get_lineage(schedule) |> 
      dplyr::select(from_name, to_name)
    
    expect_snapshot(lineage)
  })
})