# build_schedule works on a directory of all good pipelines

    Code
      res
    Output
      # A tibble: 14 x 12
         script_path     pipe_name frequency start_time          skip  log_level hours
         <chr>           <chr>     <chr>     <dttm>              <lgl> <chr>     <lis>
       1 test_pipelines~ get_mtca~ 1 day     2024-03-01 09:00:00 FALSE INFO      <int>
       2 test_pipelines~ wait      3 month   1970-01-01 00:00:00 FALSE WARN      <int>
       3 test_pipelines~ add       3 month   1970-01-01 00:00:00 FALSE INFO      <int>
       4 test_pipelines~ something 3 month   1970-01-01 00:00:00 FALSE INFO      <int>
       5 test_pipelines~ something daily     1970-01-01 00:00:00 FALSE INFO      <int>
       6 test_pipelines~ get_mtca~ 1 day     2024-03-01 09:00:00 FALSE INFO      <int>
       7 test_pipelines~ pipe      30 minute 1970-01-01 00:00:00 FALSE INFO      <int>
       8 test_pipelines~ specific~ daily     1970-01-01 00:00:00 FALSE INFO      <int>
       9 test_pipelines~ specific~ daily     1970-01-01 00:00:00 FALSE INFO      <int>
      10 test_pipelines~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <dbl>
      11 test_pipelines~ specific~ biweekly  1970-01-01 00:00:00 FALSE INFO      <int>
      12 test_pipelines~ specific~ weekly    1970-01-01 00:00:00 FALSE INFO      <int>
      13 test_pipelines~ specific~ monthly   1970-01-01 00:00:00 FALSE INFO      <int>
      14 test_pipelines~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <dbl>
      # i 5 more variables: months <list>, days_of_week <list>, days_of_month <list>,
      #   frequency_n <int>, frequency_unit <chr>

