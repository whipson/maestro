# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 4 x 8
        script_path     pipe_name is_func frequency interval start_time          tz   
        <chr>           <chr>     <lgl>   <chr>        <int> <dttm>              <chr>
      1 test_pipelines~ get_mtca~ TRUE    daily            1 2024-03-01 09:00:00 UTC  
      2 test_pipelines~ multiply  TRUE    monthly          3 1970-01-01 00:00:00 UTC  
      3 test_pipelines~ get_mtca~ TRUE    daily            1 2024-03-01 09:00:00 UTC  
      4 test_pipelines~ tagged_b~ FALSE   daily            1 1970-01-01 00:00:00 UTC  
      # i 1 more variable: skip <lgl>

