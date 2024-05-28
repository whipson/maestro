test_that("end to end workflow test", {

  schedule <- build_schedule(
    test_path("test_pipelines_parse_all_good")
  )

  expect_message({
    run_schedule(
      schedule,
      orch_frequency = "1 hour",
      check_datetime = as.POSIXct("2024-04-25 9:00:00", tz = "UTC")
    )
  })
}) |>
  suppressMessages()
