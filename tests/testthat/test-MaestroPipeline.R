test_that("Simple pipeline, no errors", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )

  pipeline <- pipeline_list$MaestroPipelines[[1]]
  expect_s3_class(pipeline, "MaestroPipeline")

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status())

  pipeline$run(quiet = TRUE)

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])
})

test_that("Pipeline with warnings", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines_run_two_warnings/pipe_warning.R")
  )
  pipeline <- pipeline_list$MaestroPipelines[[1]]

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status())

  pipeline$run(quiet = TRUE)

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])
})

test_that("Pipeline with errors", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines_run_some_errors/pipe2.R")
  )
  pipeline <- pipeline_list$MaestroPipelines[[1]]

  expect_error(pipeline$run(quiet = TRUE))

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])
})

test_that("Pipeline with arguments are correctly passed", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines_run_args_good/pipe1.R")
  )

  pipeline <- pipeline_list$MaestroPipelines[[1]]

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])

  pipeline$run(resources = list(
    vals = 1:5
  ), quiet = TRUE)

  expect_snapshot(pipeline$get_schedule())
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])
})

test_that("Logging threshold", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines_run_logs_warn/pipe_warning.R")
  )

  pipeline <- pipeline_list$MaestroPipelines[[1]]

  withr::with_tempfile("log", {

    pipeline$run(
      log_file = log,
      quiet = TRUE
    )

    logs <- readLines(log)
    expect_true(!all(grepl("INFO", logs)))
    expect_true(any(grepl("WARN", logs)))
  })

  withr::with_tempfile("log", {
    pipeline$run(
      log_file = log,
      log_file_max_bytes = 1000,
      quiet = TRUE
    )

    expect_lte(file.size(log), 1000 + 100) # margin of error
  })
})


