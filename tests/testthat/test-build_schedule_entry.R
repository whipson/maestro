test_that("can create a schedule entry from a single well-documented fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )
  expect_s3_class(res, "MaestroPipelineList")
})

test_that("can create a schedule entry from a default tagged fun", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_default.R")
  )
  expect_s3_class(res, "MaestroPipelineList")
  expect_equal(length(res$MaestroPipelines), 1)
})

test_that("invalid tags trigger error", {
  build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_bad.R")
  ) |>
    expect_error(regexp = "Invalid maestroFrequency")
}) |>
  suppressMessages()

test_that("can create a schedule entry from a multi-function script", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_multi_fun_pipeline.R")
  )
  expect_s3_class(res, "MaestroPipelineList")
  expect_equal(length(res$MaestroPipelines), 2)
}) |>
  suppressMessages()

test_that("Errors on a pipeline with no tagged functions", {
  build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/test_pipeline_no_func.R")
  ) |>
    expect_error(regexp = "tags present in")
}) |>
  suppressMessages()

test_that("Errors on pipeline that doesn't use functions and returns null", {

  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/tagged_but_no_func.R")
    )
  }, regexp = "has tags but no function")
}) |>
  suppressMessages()

test_that("Errors on pipeline with isolated tags", {
  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/tagged_but_no_func_multi.R")
    )
  }, regexp = "has tags but no function")
})

test_that("Informative error on parsing schedule entry with an error", {
  expect_error({
    res <- build_schedule_entry(
      test_path("test_pipelines_parse_all_bad/test_pipeline_script_with_error.R")
    )
  }, regexp = "Could not build")
})

test_that("Script with untagged function isn't treated as a scheduled pipeline", {
  res <- build_schedule_entry(
    test_path("test_pipelines_parse_all_good/pipe_with_custom_fun.R")
  )
  expect_equal(length(res$MaestroPipelines), 1)
})

test_that("Script with good specifiers parses well", {
  expect_no_error({
    schedule <- build_schedule_entry(
      test_path("test_pipelines_parse_all_good/specifiers.R")
    )
  })
})

test_that("Script with bad specifiers errors", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/specifiers.R")
  ) |>
    expect_error(regexp = "pipeline must have")
})

test_that("Pipeline with inputs checks for .input", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/dags.R")
  ) |>
    expect_error(regexp = "pipeline must have a parameter")

  expect_no_error({
    schedule <- build_schedule_entry(
      test_path("test_pipelines_dags_good/dags.R")
    )
  })
})

test_that("Errors if pipeline self-references as input", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/dags_self_reference_inputs.R")
  ) |>
    expect_error(regexp = "cannot contain self-references")
})

test_that("Errors if pipeline self-references as output", {
  schedule <- build_schedule_entry(
    test_path("test_pipelines_parse_all_bad/dags_self_reference_outputs.R")
  ) |>
    expect_error(regexp = "cannot contain self-references")
})

test_that("Pipelines with maestro tag get picked up", {
  res <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_maestro.R")
  )
  expect_equal(length(res$MaestroPipelines), 1)
})

test_that("Pipelines with maestroHours and maestroFrequency = 1 hour are valid", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroTz America/Halifax
      #' @maestroFrequency 1 hour
      #' @maestroStartTime 2025-01-01 00:00:00
      #' @maestroHours 0 4 7 12 18
      hourly <- function() {

      }
      ",
      con = "pipelines/hourly.R"
    )

    expect_no_error({
      build_schedule_entry("pipelines/hourly.R")
    })
  })
})
