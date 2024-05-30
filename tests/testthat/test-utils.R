test_that("convert_to_seconds works", {

  res <- convert_to_seconds("1 week")
  expect_equal(res, unclass(lubridate::duration(1, units = "week")))

  res <- convert_to_seconds("12 hours")
  expect_equal(res, unclass(lubridate::duration(12, units = "hours")))

  res <- convert_to_seconds("25minutes")
  expect_equal(res, unclass(lubridate::duration(25, units = "minutes")))

  res <- convert_to_seconds("48    days")
  expect_equal(res, unclass(lubridate::duration(48, units = "days")))

  res <- convert_to_seconds("1 quarters")
  expect_equal(res, 7884000L)
})

test_that("parse_rounding_unit works", {

  good_examples <- c(
    "1 days", "4 weeks", "10 months", "2 week",
    "15 minute", "30 day  ", " 20 hours", "2 years",
    "2 quarters", "19 mins"
  )

  purrr::walk(good_examples, ~{
    expect_no_error(
      parse_rounding_unit(.x)
    )
  })

  bad_examples <- c(
    "one day", "45 daysasd", "3 hrs", "4"
  )

  purrr::walk(bad_examples, ~{
    expect_error(
      parse_rounding_unit(.x),
      regexp = "Invalid"
    )
  })
})
