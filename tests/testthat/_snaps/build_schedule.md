# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 4 x 7
        script_path   pipe_name frequency interval start_time          skip  log_level
        <chr>         <chr>     <chr>        <int> <dttm>              <lgl> <chr>    
      1 test_pipelin~ get_mtca~ day              1 2024-03-01 09:00:00 FALSE INFO     
      2 test_pipelin~ wait      month            3 1970-01-01 00:00:00 FALSE WARN     
      3 test_pipelin~ get_mtca~ day              1 2024-03-01 09:00:00 FALSE INFO     
      4 test_pipelin~ pipe      minute           1 1970-01-01 00:00:00 FALSE INFO     

