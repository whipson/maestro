schedule <- build_schedule(test_path("test_pipelines_run_all_good"), quiet = TRUE)

test_that("invoke errors if schedule is not a MaestroSchedule", {
  expect_error({
    invoke(iris, pipe_name = "hello")
  }, regexp = "Schedule must be an object")
})

test_that("invoke errors if pipe_name is not a single character", {

  expect_error({
    invoke(schedule, pipe_name = letters)
  }, regexp = "must be a single character")
})

test_that("invoke errors if pipe_name is not in the schedule", {
  expect_error({
    invoke(schedule, pipe_name = "I don't exist")
  }, regexp = "is not the name of a pipeline in the schedule")
})

test_that("errors if resources are unnamed or non unique", {

  expect_error({
    invoke(schedule, "chatty", quiet = TRUE, resources = list(4))
  }, regexp = "All elements")

  expect_error({
    invoke(schedule, "chatty", quiet = TRUE, resources = list(a = 1, a = 2))
  }, regexp = "All elements")
})

test_that("invoke triggers the pipeline", {

  expect_no_error({
    invoke(schedule, "chatty", quiet = TRUE)
  })

  status <- schedule$get_status()
  expect_true(status$invoked[status$pipe_name == "chatty"])
})
