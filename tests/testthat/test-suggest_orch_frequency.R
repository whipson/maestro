test_that("suggest_orch_frequency gives valid suggestions", {

  expect_equal(
    suggest_orch_frequency(example_schedule),
    "30 mins"
  )

  test_schedule <- data.frame(
    frequency = "1 day",
    frequency_n = 1,
    frequency_unit = "day",
    start_time = as.POSIXct("2024-01-01") + lubridate::hours(0:1)
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "1 hours"
  )

  test_schedule <- data.frame(
    frequency = c("5 months", "1 quarter"),
    frequency_n = c(5, 1),
    frequency_unit = c("months", "quarter"),
    start_time = as.POSIXct("2024-05-20")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "31 days"
  )

  test_schedule <- data.frame(
    frequency = c("1 days", "3 days"),
    frequency_n = c(1, 3),
    frequency_unit = c("day"),
    start_time = as.POSIXct("2024-06-04")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "1 days"
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
  }, regexp = "Schedule must be a data.frame")

  expect_error({
    suggest_orch_frequency(data.frame())
  }, regexp = "Empty schedule")

  expect_error(
    suggest_orch_frequency(iris),
    regexp = "Schedule is missing required column"
  )

  expect_error(
    suggest_orch_frequency(data.frame(frequency = 14, start_time = Sys.time())),
    regexp = "Schedule columns `frequency` must have type"
  )

  expect_error(
    suggest_orch_frequency(data.frame(frequency = "1 day")),
    regexp = "Schedule is missing required column 'start_time'"
  )

  expect_error(
    suggest_orch_frequency(data.frame(frequency = c("1 day", "1 month"), start_time = c("a", "b"))),
    regexp = "Schedule columns `start_time`"
  )

  expect_error(
    suggest_orch_frequency(data.frame(frequency = c("daily", "1 month"), start_time = Sys.time() + 0:1, skip = "hello")),
    regexp = "Schedule columns `skip`"
  )
})

test_that("suggest_orch_frequency does not consider skipped pipelines", {

  test_schedule <- data.frame(
    frequency = c("1 days", "3 days", "6 days"),
    frequency_n = c(1, 3, 6),
    frequency_unit = c("day", "day", "day"),
    start_time = as.POSIXct("2024-06-04"),
    skip = c(TRUE, FALSE, FALSE)
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "3 days"
  )

  test_schedule <- data.frame(
    frequency = c("1 days", "3 days", "6 days"),
    frequency_n = c(1, 3, 6),
    frequency_unit = c("day", "day", "day"),
    start_time = as.POSIXct("2024-06-04"),
    skip = TRUE
  )

  expect_error(
    suggest_orch_frequency(test_schedule),
    regexp = "No pipelines in schedule after removing skipped"
  )
})

test_that("suggest_orch_frequency works with a single pipeline", {

  test_schedule <- data.frame(
    frequency = "1 day",
    frequency_n = 1,
    frequency_unit = "day",
    start_time = as.POSIXct("2024-01-01")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "1 day"
  )
})

