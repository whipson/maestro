test_that("Simple pipeline list, no errors", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )

  expect_s3_class(pipeline_list, "MaestroPipelineList")
  expect_snapshot(pipeline_list)
  expect_type(pipeline_list$get_pipe_names(), "character")
  expect_s3_class(pipeline_list$get_pipe_by_name("get_mtcars"), "MaestroPipeline")
  expect_error(
    pipeline_list$get_pipe_by_name("asdasd"),
    regexp = "No pipeline"
  )

  pipeline_list$run(quiet = TRUE)
  pipeline <- pipeline_list$MaestroPipelines[[1]]
  expect_snapshot(pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")])

  expect_type(
    pipeline_list$check_timeliness(orch_n = 1, orch_unit = "day"),
    "logical"
  )

  expect_s3_class(
    pipeline_list$get_timely_pipelines(orch_n = 1, orch_unit = "day"),
    "MaestroPipelineList"
  )
})

test_that("Errors are handled", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines_run_some_errors/pipe2.R")
  )

  expect_no_error(pipeline_list$run(quiet = TRUE))
})

test_that("Populate on instantiation", {

  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )

  pipelines <- pipeline_list$MaestroPipelines

  new_pipeline_list <- MaestroPipelineList$new(pipelines)
  expect_s3_class(new_pipeline_list, "MaestroPipelineList")
  expect_s3_class(new_pipeline_list$MaestroPipelines[[1]], "MaestroPipeline")
})

test_that("Populate after instantiation", {
  pipeline_list <- build_schedule_entry(
    test_path("test_pipelines/test_pipeline_daily_good.R")
  )

  pipelines <- pipeline_list$MaestroPipelines

  new_pipeline_list <- MaestroPipelineList$new()
  new_pipeline_list$add_pipelines(pipelines[[1]])
  expect_s3_class(new_pipeline_list, "MaestroPipelineList")
  expect_s3_class(new_pipeline_list$MaestroPipelines[[1]], "MaestroPipeline")
})
