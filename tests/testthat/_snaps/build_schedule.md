# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 3 x 6
        script_path             pipe_name frequency interval start_time          skip 
        <chr>                   <chr>     <chr>        <int> <dttm>              <lgl>
      1 test_pipelines_parse_a~ get_mtca~ day              1 2024-03-01 09:00:00 FALSE
      2 test_pipelines_parse_a~ wait      month            3 1970-01-01 00:00:00 FALSE
      3 test_pipelines_parse_a~ get_mtca~ day              1 2024-03-01 09:00:00 FALSE

