test_that("end to end workflow test", {

  schedule <- build_schedule(
    test_path("test_pipelines_all_good")
  )

  expect_message({
    run_schedule(schedule)
  })
}) |>
  suppressMessages()
