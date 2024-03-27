test_that(
  "Check input types",
  {
    res_false <- identify_pipelines(orch_interval = 15,
                                    orch_unit = "mins",
                                    check_datetime = lubridate::force_tz(lubridate::as_datetime("2024-03-27 05:05:00"), tzone = "America/Halifax"),
                                    pipeline_interval = 1,
                                    pipeline_freq = "day",
                                    pipeline_datetime = lubridate::force_tz(lubridate::as_datetime("2024-01-01 05:05:00"), tzone = "America/Halifax")
    )

    res_true <- identify_pipelines(orch_interval = 15,
                                   orch_unit = "mins",
                                   check_datetime = lubridate::force_tz(lubridate::as_datetime("2024-03-27 05:05:00"), tzone = "America/Halifax"),
                                   pipeline_interval = 1,
                                   pipeline_freq = "day",
                                   pipeline_datetime = lubridate::force_tz(lubridate::as_datetime("2024-03-21 05:05:00"), tzone = "America/Halifax")
    )

    expect_type(res_false, "logical")
    expect_type(res_true, "logical")
    expect_equal(res_false, FALSE)
    expect_equal(res_true, TRUE)
  }
)
