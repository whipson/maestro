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
