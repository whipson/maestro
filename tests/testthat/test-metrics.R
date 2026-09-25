test_that("update_metric records a scalar metric retrievable via get_metrics", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 100)
        update_metric('rows_out', 95)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_s3_class(metrics, "data.frame")
    expect_setequal(names(metrics), c("pipe_name", "run_id", "metric", "value"))
    expect_equal(nrow(metrics), 2)
    expect_equal(unique(metrics$pipe_name), "metric_pipe")
    expect_equal(metrics$value[metrics$metric == "rows_in"][[1]], 100)
    expect_equal(metrics$value[metrics$metric == "rows_out"][[1]], 95)
  })
})

test_that("repeated update_metric calls with the same name overwrite", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 100)
        update_metric('rows_in', 101)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 1)
    expect_equal(metrics$value[[1]], 101)
  })
})

test_that("update_metric with increment = TRUE adds to the existing value", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 1, increment = TRUE)
        update_metric('rows_in', 2, increment = TRUE)
        update_metric('rows_in', 3, increment = TRUE)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 1)
    expect_equal(metrics$value[[1]], 6)
  })
})

test_that("update_metric with increment = TRUE behaves like a regular update when the metric doesn't exist yet", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 5, increment = TRUE)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 1)
    expect_equal(metrics$value[[1]], 5)
  })
})

test_that("update_metric with increment = TRUE and a negative value decrements", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 10, increment = TRUE)
        update_metric('rows_in', -3, increment = TRUE)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 1)
    expect_equal(metrics$value[[1]], 7)
  })
})

test_that("get_metrics returns a numeric value column", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 100L)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 1)
    expect_type(metrics$value, "double")
    expect_equal(metrics$value[[1]], 100)
  })
})

test_that("metrics accumulate separately across multiple schedule runs", {
  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      metric_pipe <- function() {
        update_metric('rows_in', 1)
      }
      ",
      con = "pipelines/metric_pipe.R"
    )

    schedule <- build_schedule(quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)
    schedule <- run_schedule(schedule, run_all = TRUE, quiet = TRUE)

    metrics <- get_metrics(schedule)

    expect_equal(nrow(metrics), 2)
    expect_equal(length(unique(metrics$run_id)), 2)
  })
})

test_that("update_metric emits a message and has no effect when called outside a pipeline run", {
  expect_message(
    result <- update_metric("rows_in", 1),
    regexp = "outside of a pipeline run"
  )
  expect_null(result)
})

test_that("update_metric validates name and value", {
  expect_error(update_metric(c("a", "b"), 1), regexp = "single, non-missing, non-empty string")
  expect_error(update_metric(NA_character_, 1), regexp = "single, non-missing, non-empty string")
  expect_error(update_metric("", 1), regexp = "single, non-missing, non-empty string")
  expect_error(update_metric("x", list(1, 2)), regexp = "numeric scalar")
  expect_error(update_metric("x", character(0)), regexp = "numeric scalar")
  expect_error(update_metric("x", "a"), regexp = "numeric scalar")
  expect_error(update_metric("x", c(1, 2)), regexp = "numeric scalar")
  expect_error(update_metric("x", TRUE), regexp = "numeric scalar")
  expect_error(update_metric("x", NA_real_), regexp = "must not be `NA`")
  expect_error(update_metric("x", 1, increment = "yes"), regexp = "increment.*must be a single, non-missing logical")
  expect_error(update_metric("x", 1, increment = NA), regexp = "increment.*must be a single, non-missing logical")
  expect_error(update_metric("x", 1, increment = c(TRUE, FALSE)), regexp = "increment.*must be a single, non-missing logical")
})

test_that("get_metrics errors if schedule is not a MaestroSchedule", {
  expect_error(
    get_metrics(iris),
    regexp = "Schedule must be an object"
  )
})

test_that("Multicore metrics round-trip through worker processes", {

  # Uses a fixture directory (absolute path via test_path()) rather than
  # withr::with_tempdir(), because multisession workers do not share the main
  # process's working directory - relative script paths fail to resolve there.
  testthat::skip_if(Sys.getenv("MAESTRO_TEST_FUTURE") != "true")
  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_run_metrics"))
  schedule <- run_schedule(schedule, run_all = TRUE, cores = 2)

  metrics <- get_metrics(schedule)
  expect_equal(nrow(metrics), 1)
  expect_equal(metrics$value[[1]], 42)

  future::plan(future::sequential)
}) |>
  suppressMessages()
