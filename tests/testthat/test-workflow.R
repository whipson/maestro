# test_that("end to end workflow test", {
#
#   schedule <- build_schedule(
#     test_path("test_pipelines_parse_all_good")
#   )
#
#   expect_message({
#     run_schedule(
#       schedule,
#       orch_interval = 1,
#       orch_unit = "day"
#     )
#   })
# }) |>
#   suppressMessages()
