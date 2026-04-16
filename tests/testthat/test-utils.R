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

test_that("parse_maestro_start_time handles HH:MM:SS", {
  now <- as.POSIXct("2026-04-14 10:00:00", tz = "UTC")
  result <- parse_maestro_start_time("04:00:00", tz = "UTC", now = now)
  expect_s3_class(result, "POSIXct")
  expect_equal(format(result, "%H:%M:%S"), "04:00:00")
  expect_equal(format(result, "%Y-%m-%d"), "2026-04-13")
})

test_that("parse_maestro_start_time handles weekday + time", {
  # 2026-04-14 is a Tuesday; Mon of that week is 2026-04-13
  now <- as.POSIXct("2026-04-14 10:00:00", tz = "UTC")

  mon <- parse_maestro_start_time("Mon 04:00:00", tz = "UTC", now = now)
  expect_s3_class(mon, "POSIXct")
  expect_equal(format(mon, "%Y-%m-%d %H:%M:%S"), "2026-04-13 04:00:00")

  wed <- parse_maestro_start_time("Wed 09:30:00", tz = "UTC", now = now)
  expect_equal(format(wed, "%Y-%m-%d %H:%M:%S"), "2026-04-15 09:30:00")

  sun <- parse_maestro_start_time("Sun 00:00:00", tz = "UTC", now = now)
  expect_equal(format(sun, "%Y-%m-%d %H:%M:%S"), "2026-04-19 00:00:00")
})

test_that("parse_maestro_start_time weekday anchor is deterministic across calls", {
  now <- as.POSIXct("2026-04-14 10:00:00", tz = "UTC")
  r1 <- parse_maestro_start_time("Mon 04:00:00", tz = "UTC", now = now)
  r2 <- parse_maestro_start_time("Mon 04:00:00", tz = "UTC", now = now)
  expect_equal(r1, r2)
})

test_that("parse_maestro_start_time handles month-day + time", {
  now <- as.POSIXct("2026-04-14 10:00:00", tz = "UTC")

  result <- parse_maestro_start_time("15 04:00:00", tz = "UTC", now = now)
  expect_s3_class(result, "POSIXct")
  expect_equal(format(result, "%Y-%m-%d %H:%M:%S"), "2026-04-15 04:00:00")

  result1 <- parse_maestro_start_time("1 00:00:00", tz = "UTC", now = now)
  expect_equal(format(result1, "%Y-%m-%d %H:%M:%S"), "2026-04-01 00:00:00")
})

test_that("parse_maestro_start_time handles bare month-day (no time)", {
  now <- as.POSIXct("2026-04-14 10:00:00", tz = "UTC")
  result <- parse_maestro_start_time("15", tz = "UTC", now = now)
  expect_s3_class(result, "POSIXct")
  expect_equal(format(result, "%Y-%m-%d %H:%M:%S"), "2026-04-15 00:00:00")
})

test_that("parse_maestro_start_time handles full datetime", {
  result <- parse_maestro_start_time("2025-06-01 08:00:00", tz = "UTC")
  expect_s3_class(result, "POSIXct")
  expect_equal(format(result, "%Y-%m-%d %H:%M:%S"), "2025-06-01 08:00:00")
})

test_that("parse_maestro_start_time returns NA for NA input", {
  result <- parse_maestro_start_time(NA, tz = "UTC")
  expect_true(is.na(result))
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
