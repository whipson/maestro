# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 6 x 6
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>         <dbl> <dttm>              <lgl> <chr>    
      1 test_pipelines_parse_~ get_mtca~     86400 2024-03-01 09:00:00 FALSE INFO     
      2 test_pipelines_parse_~ wait        7889400 1970-01-01 00:00:00 FALSE WARN     
      3 test_pipelines_parse_~ add         7889400 1970-01-01 00:00:00 FALSE INFO     
      4 test_pipelines_parse_~ something   7889400 1970-01-01 00:00:00 FALSE INFO     
      5 test_pipelines_parse_~ get_mtca~     86400 2024-03-01 09:00:00 FALSE INFO     
      6 test_pipelines_parse_~ pipe             60 1970-01-01 00:00:00 FALSE INFO     

