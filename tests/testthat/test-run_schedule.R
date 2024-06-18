test_that("run_schedule works", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_message({
    output <- run_schedule(schedule, run_all = TRUE)
  })
  status <- output$status

  expect_s3_class(status, "data.frame")
  expect_in(
    c("pipe_name", "script_path", "invoked", "success", "pipeline_started",
      "pipeline_ended", "errors", "warnings", "messages", "next_run"
    ),
    names(status)
  )

  expect_type(
    output$artifacts, "list"
  )
  expect_gt(length(output$artifacts), 0)

  expect_s3_class(status$pipeline_started, "POSIXct")
  expect_gt(nrow(status), 0)
  expect_length(last_run_errors(), 0)
  expect_length(last_run_warnings(), 0)
}) |>
  suppressMessages()

test_that("run_schedule correctly returns artifacts (i.e., pipeline returns)", {

  schedule <- build_schedule(test_path("test_pipelines_run_artifacts"))

  output <- run_schedule(schedule, run_all = TRUE)

  artifacts <- output$artifacts

  expect_length(artifacts, 1)
  expect_equal(artifacts[[1]], "I'm an artifact")
}) |>
  suppressMessages()

test_that("run_schedule works when not running all (verification of checking)", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_message({
    run_schedule(schedule)
  })
}) |>
  suppressMessages()

test_that("run_schedule works with a future check_datetime", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  expect_message({
    run_schedule(
      schedule,
      check_datetime = as.POSIXct("5000-10-10 12:00:00")
    )
  })
}) |>
  suppressMessages()

test_that("run_schedule works on different kinds of frequencies", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  test_freqs <- c("14 days", "10 minutes", "25 mins", "1 week",
                  "1 quarter", "12 months", "4 years", "24 hours",
                  "31 days", "1 secs", "50 seconds")

  purrr::walk(test_freqs, ~{
    expect_no_error({
      run_schedule(
        schedule,
        orch_frequency = .x
      )
    })
  })
}) |>
  suppressMessages()

test_that("run_schedule with quiet=TRUE prints no messages", {
  schedule <- build_schedule(test_path("test_pipelines_run_all_good")) |>
    suppressMessages()

  expect_no_message({
    run_schedule(schedule, run_all = TRUE, quiet = TRUE)
  })
})

test_that("run_schedule fails on a pipeline that doesn't exist", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  schedule_with_missing <- schedule |>
    dplyr::add_row(
      script_path = "nonexistent",
      pipe_name = "im_a_problem",
      frequency = "10 days",
      start_time = as.POSIXct("1970-01-01 00:00:00")
    )

  expect_error(
    run_schedule(schedule_with_missing, run_all = TRUE),
    regexp = "Schedule has column"
  )
}) |>
  suppressMessages()

test_that("run_schedule timeliness checks - pipelines run when they're supposed to", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

  output <- run_schedule(
    schedule,
    orch_frequency = "15 minutes",
    check_datetime = as.POSIXct("2024-04-25 09:35:00", tz = "UTC"),
    quiet = TRUE
  )

  status <- output$status

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  output <- run_schedule(
    schedule,
    orch_frequency = "1 month",
    check_datetime = as.POSIXct("2024-04-01 00:00:00", tz = "UTC"),
    quiet = TRUE
  )
  status <- output$status

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )

  output <- run_schedule(
    schedule,
    orch_frequency = "4 days",
    check_datetime = as.POSIXct("2024-04-01 00:00:00", tz = "UTC"),
    quiet = TRUE
  )
  status <- output$status

  expect_snapshot(
    status$invoked
  )
  expect_snapshot(
    status$next_run
  )
})

test_that("run_schedule propagates warnings", {

  schedule <- build_schedule(test_path("test_pipelines_run_two_warnings"))

  expect_message({
    run_schedule(schedule, run_all = TRUE)
  })
  expect_gt(length(last_run_warnings()), 0)
}) |>
  suppressMessages()

test_that("run_schedule handles errors in a pipeline", {

  schedule <- build_schedule(test_path("test_pipelines_run_some_errors"))

  temp <- tempfile()

  expect_message({
    output <- run_schedule(schedule, run_all = TRUE, logging = TRUE, log_file = temp)
  })
  status <- output$status

  expect_gt(length(readLines(temp)), 0)
  file.remove(temp)

  errors <- last_run_errors()
  expect_type(errors, "list")
  expect_length(errors, 1)
  expect_true(all(!is.na(status$pipeline_started)))
}) |>
  suppressMessages()

test_that("run_schedule checks schedule validity in the event of orchestration error", {

  # Not a data.frame
  not_a_schd <- "I'm a string"
  expect_error(
    run_schedule(not_a_schd, run_all = TRUE),
    regexp = "Schedule must be a data.frame"
  )

  # Empty data.frame
  bad_schedule <- data.frame()
  expect_error(
    run_schedule(bad_schedule, run_all = TRUE),
    regexp = "Empty schedule"
  )

  # Nonexistent required columns
  expect_error(
    run_schedule(iris, run_all = TRUE),
    regexp = "Schedule is missing required columns"
  )
}) |>
  suppressMessages()

test_that("run_schedule correctly passes arguments", {

  schedule <- build_schedule(test_path("test_pipelines_run_args_good"))

  # Runtime error if a pipe requires an argument but it's not provided
  run_schedule(
    schedule,
    run_all = TRUE
  )
  expect_gt(length(last_run_errors()), 0)

  # Works
  run_schedule(
    schedule,
    resources = list(
      vals = 1:5
    ),
    run_all = TRUE
  )
  expect_length(last_run_errors(), 0)

  # Argument provided
  run_schedule(
    schedule,
    resources = list(
      1:5
    ),
    run_all = TRUE
  ) |>
    expect_error(regexp = "All elements")
}) |>
  suppressMessages()

test_that("run_schedule correctly thresholds logging at warn", {

  schedule <- build_schedule(test_path("test_pipelines_run_logs_warn"))

  temp <- tempfile()

  run_schedule(
    schedule,
    run_all = TRUE,
    logging = TRUE,
    log_file = temp
  )

  logs <- readLines(temp)
  file.remove(temp)
  expect_true(!all(grepl("INFO", logs)))
  expect_true(any(grepl("WARN", logs)))
}) |>
  suppressMessages()

test_that("run_schedule correctly trims log file", {

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  temp <- tempfile()

  run_schedule(
    schedule,
    run_all = TRUE,
    logging = TRUE,
    log_file = temp,
    log_file_max_bytes = 1000,
    quiet = TRUE
  )

  expect_lte(file.size(temp), 1000 + 100) # margin of error
  file.remove(temp)
}) |>
  suppressMessages()

test_that("run_schedule works with multiple cores", {

  future::plan(future::multisession(workers = 2))

  schedule <- build_schedule(test_path("test_pipelines_run_all_good"))

  temp <- tempfile()

  expect_no_error({
    output <- run_schedule(
      schedule,
      cores = 2,
      run_all = TRUE,
      logging = TRUE,
      log_file = temp
    )
  })

  status <- output$status

  expect_true(all(status$success))

  expect_gt(length(readLines(temp)), 0)
  file.remove(temp)
  expect_length(last_run_errors(), 0)
}) |>
  suppressMessages()
