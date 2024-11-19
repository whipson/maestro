# get_schedule returns a data.frame

    Code
      schedule
    Message
      
      -- Maestro Schedule with 7 pipelines:  
      * Not Run

# get_schedule works with DAG schedules

    Code
      get_schedule(schedule)
    Output
      # A tibble: 11 x 9
         script_path     pipe_name frequency start_time          tz    skip  log_level
         <chr>           <chr>     <chr>     <dttm>              <chr> <lgl> <chr>    
       1 test_pipelines~ with_inp~ <NA>      NA                  <NA>  FALSE INFO     
       2 test_pipelines~ primary   daily     2024-01-01 00:00:00 UTC   FALSE INFO     
       3 test_pipelines~ trunk     daily     2024-01-01 00:00:00 UTC   FALSE INFO     
       4 test_pipelines~ branch1   <NA>      NA                  <NA>  FALSE INFO     
       5 test_pipelines~ branch2   <NA>      NA                  <NA>  FALSE INFO     
       6 test_pipelines~ subbranc~ <NA>      NA                  <NA>  FALSE INFO     
       7 test_pipelines~ subbranc~ <NA>      NA                  <NA>  FALSE INFO     
       8 test_pipelines~ start     daily     2024-01-01 00:00:00 UTC   FALSE INFO     
       9 test_pipelines~ high_road <NA>      NA                  <NA>  FALSE INFO     
      10 test_pipelines~ low_road  <NA>      NA                  <NA>  FALSE INFO     
      11 test_pipelines~ end       <NA>      NA                  <NA>  FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

