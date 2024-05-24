df_schedule <- build_schedule(
  pipeline_dir = test_path("test_pipelines_parse_all_good")
) |>
  suppressMessages()

test_that(
  "Check check_pipelines works on sample data.frame",
  {
    res <- check_pipelines(
      df_schedule,
      orch_interval = 15,
      orch_frequency = "minute",
      check_datetime = lubridate::force_tz(lubridate::as_datetime("2024-03-27 07:13:12"), "America/Halifax")
    )

    expect_type(res, "list")
  }
)

test_that(
  "Expect error on invalid orch_interval",
  {
    expect_error(
      check_pipelines(
        df_schedule,
        orch_interval = "a",
        orch_frequency = "minute",
        check_datetime = Sys.time()
      )
    )
  }
)

test_that(
  "Expect error on invalid orch_frequency",
  {
    expect_error(
      check_pipelines(
        df_schedule,
        orch_interval = 15,
        orch_frequency = 1,
        check_datetime = Sys.time()
      )
    )
  }
)


