test_that(
  "Check select_pipeline works on sample data.frame",
  {
    res <- select_pipelines(
      df_schedule,
      orch_interval = 15,
      orch_unit = "minute",
      check_datetime = lubridate::force_tz(lubridate::as_datetime("2024-03-27 07:13:12"), "America/Halifax")
    )

    expect_snapshot(res)

    expect_s3_class(res, "data.frame")

    expect_type(res$pipeline_name, "character")
    expect_s3_class(res$start_time, c("POSIXct", "POSIXt"))
    expect_type(res$frequency, "character")
    expect_equal(class(res$interval), "numeric")

    expect_in(
      c("pipeline_name", "start_time", "frequency", "interval"),
      names(res)
    )

    expect_equal(nrow(res), 2)
  }
)

test_that(
  "Expect error on invalid orch_interval",
  {
    expect_error(
      select_pipelines(
        df_schedule,
        orch_interval = "a",
        orch_unit = "minute",
        check_datetime = Sys.time()
      )
    )
  }
)

test_that(
  "Expect error on invalid orch_unit",
  {
    expect_error(
      select_pipelines(
        df_schedule,
        orch_interval = 15,
        orch_unit = 1,
        check_datetime = Sys.time()
      )
    )
  }
)


