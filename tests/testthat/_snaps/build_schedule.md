# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 4 x 7
        script_path     pipe_name is_func frequency interval start_time          skip 
        <chr>           <chr>     <lgl>   <chr>        <int> <dttm>              <lgl>
      1 test_pipelines~ get_mtca~ TRUE    day              1 2024-03-01 09:00:00 FALSE
      2 test_pipelines~ wait      TRUE    month            3 1970-01-01 00:00:00 FALSE
      3 test_pipelines~ get_mtca~ TRUE    day              1 2024-03-01 09:00:00 FALSE
      4 test_pipelines~ tagged_b~ FALSE   day              1 1970-01-01 00:00:00 FALSE

