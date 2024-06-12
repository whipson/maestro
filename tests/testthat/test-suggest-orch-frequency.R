test_that("suggest_orch_frequency gives valid suggestions", {

  test_schedule <- data.frame(
    frequency = c("1 hour", "2 days", "3 hours", "4 weeks")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "30 minutes"
  )

  test_schedule <- data.frame(
    frequency = c("15 minutes", "4 years", "10 days")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "15 minutes"
  )

  test_schedule <- data.frame(
    frequency = c("5 months", "1 quarter")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "2 months"
  )

  test_schedule <- data.frame(
    frequency = c("5 minute", "10 minute")
  )

  expect_equal(
    suggest_orch_frequency(test_schedule),
    "5 minute"
  )
})
