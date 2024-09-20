example_schedule <- build_schedule(test_path("test_pipelines_parse_all_good"), quiet = TRUE)

test_that("suggest_orch_frequency gives valid suggestions", {

  expect_equal(
    suggest_orch_frequency(example_schedule),
    "30 mins"
  )
})

test_that("suggest_orch_frequency works when check_datetime is a Date", {
  expect_no_error(
    suggest_orch_frequency(example_schedule, check_datetime = as.Date("2024-08-06"))
  )
})

test_that("suggest_orch_frequency gives expected errors", {
  expect_error({
    suggest_orch_frequency(1)
  }, regexp = "Schedule must be an object")
})

