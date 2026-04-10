test_that(".prev_on_cycle returns NA when current <= start (POSIXct)", {
  start <- as.POSIXct("2024-01-01 09:00:00", tz = "UTC")

  expect_true(is.na(.prev_on_cycle(start, current = start, unit = "hour")))
  expect_true(is.na(.prev_on_cycle(start, current = start - 1, unit = "hour")))
})

test_that(".prev_on_cycle returns NA when current <= start (Date)", {
  start <- as.Date("2024-01-01")

  expect_true(is.na(.prev_on_cycle(start, current = start, unit = "day")))
  expect_true(is.na(.prev_on_cycle(start, current = start - 1, unit = "day")))
})

test_that(".prev_on_cycle returns NA for invalid start", {
  expect_true(is.na(.prev_on_cycle(
    as.POSIXct(NA), current = as.POSIXct("2024-01-02"), unit = "day"
  )))
})

test_that(".prev_on_cycle works for seconds", {
  start <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-01 00:00:45", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 10L, unit = "second"),
    as.POSIXct("2024-01-01 00:00:40", tz = "UTC")
  )
})

test_that(".prev_on_cycle works for minutes", {
  start <- as.POSIXct("2024-01-01 09:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-01 09:47:00", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 15L, unit = "minute"),
    as.POSIXct("2024-01-01 09:45:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle works for hours", {
  start <- as.POSIXct("2024-01-01 06:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-01 20:00:01", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 2L, unit = "hour"),
    as.POSIXct("2024-01-01 20:00:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle works for days", {
  start <- as.POSIXct("2024-01-01 09:35:00", tz = "UTC")
  current <- as.POSIXct("2024-01-08 09:35:01", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 3L, unit = "day"),
    as.POSIXct("2024-01-07 09:35:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle works for weeks", {
  start <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-22 00:00:01", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 2L, unit = "week"),
    as.POSIXct("2024-01-15 00:00:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle does not return current when it is exactly on cycle", {
  start <- as.POSIXct("2024-01-01 09:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-01 11:00:00", tz = "UTC")

  result <- .prev_on_cycle(start, current, amount = 1L, unit = "hour")

  # Must return the previous slot, not current
  expect_equal(result, as.POSIXct("2024-01-01 10:00:00", tz = "UTC"))
})

test_that(".prev_on_cycle returns current slot when nudged by 1 second", {
  start <- as.POSIXct("2024-01-01 09:00:00", tz = "UTC")
  current <- as.POSIXct("2024-01-01 11:00:00", tz = "UTC")

  result <- .prev_on_cycle(start, current + 1, amount = 1L, unit = "hour")

  expect_equal(result, as.POSIXct("2024-01-01 11:00:00", tz = "UTC"))
})

test_that(".prev_on_cycle works for months", {
  start <- as.POSIXct("2024-01-15 09:00:00", tz = "UTC")
  current <- as.POSIXct("2024-04-20 09:00:00", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "month"),
    as.POSIXct("2024-04-15 09:00:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle clamps month-end dates for months (POSIXct)", {
  start <- as.POSIXct("2024-01-31 00:00:00", tz = "UTC")
  current <- as.POSIXct("2024-03-01 00:00:00", tz = "UTC")

  result <- .prev_on_cycle(start, current, amount = 1L, unit = "month")

  expect_equal(result, as.POSIXct("2024-02-29 00:00:00", tz = "UTC"))
})

test_that(".prev_on_cycle works for multi-month step", {
  start <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC")
  current <- as.POSIXct("2024-07-15 00:00:00", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 3L, unit = "month"),
    as.POSIXct("2024-07-01 00:00:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle works for years", {
  start <- as.POSIXct("2020-06-15 12:00:00", tz = "UTC")
  current <- as.POSIXct("2024-06-16 00:00:00", tz = "UTC")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "year"),
    as.POSIXct("2024-06-15 12:00:00", tz = "UTC")
  )
})

test_that(".prev_on_cycle clamps leap-day start for years", {
  start <- as.POSIXct("2020-02-29 00:00:00", tz = "UTC")
  current <- as.POSIXct("2023-03-01 00:00:00", tz = "UTC")

  result <- .prev_on_cycle(start, current, amount = 1L, unit = "year")

  expect_equal(result, as.POSIXct("2023-02-28 00:00:00", tz = "UTC"))
})

test_that(".prev_on_cycle preserves the start timezone", {
  start <- as.POSIXct("2024-01-01 09:00:00", tz = "America/Halifax")
  current <- as.POSIXct("2024-01-01 12:00:00", tz = "America/Halifax")

  result <- .prev_on_cycle(start, current, amount = 1L, unit = "hour")

  expect_equal(attr(result, "tzone"), "America/Halifax")
  expect_equal(result, as.POSIXct("2024-01-01 11:00:00", tz = "America/Halifax"))
})

test_that(".prev_on_cycle works for days (Date)", {
  start <- as.Date("2024-01-01")
  current <- as.Date("2024-01-10")

  expect_equal(
    .prev_on_cycle(start, current, amount = 3L, unit = "day"),
    as.Date("2024-01-07")
  )
})

test_that(".prev_on_cycle works for weeks (Date)", {
  start <- as.Date("2024-01-01")
  current <- as.Date("2024-01-20")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "week"),
    as.Date("2024-01-15")
  )
})

test_that(".prev_on_cycle works for months (Date)", {
  start <- as.Date("2024-01-15")
  current <- as.Date("2024-04-20")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "month"),
    as.Date("2024-04-15")
  )
})

test_that(".prev_on_cycle clamps month-end dates (Date)", {
  start <- as.Date("2024-01-31")
  current <- as.Date("2024-03-01")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "month"),
    as.Date("2024-02-29")
  )
})

test_that(".prev_on_cycle works for years (Date)", {
  start <- as.Date("2020-03-10")
  current <- as.Date("2024-03-11")

  expect_equal(
    .prev_on_cycle(start, current, amount = 1L, unit = "year"),
    as.Date("2024-03-10")
  )
})

test_that(".prev_on_cycle errors on sub-day unit with Date input", {
  start <- as.Date("2024-01-01")

  expect_error(.prev_on_cycle(start, as.Date("2024-01-02"), unit = "hour"))
  expect_error(.prev_on_cycle(start, as.Date("2024-01-02"), unit = "minute"))
  expect_error(.prev_on_cycle(start, as.Date("2024-01-02"), unit = "second"))
})

test_that(".prev_on_cycle errors on non-Date/POSIXct start", {
  expect_error(.prev_on_cycle("2024-01-01", Sys.time(), unit = "day"))
})
