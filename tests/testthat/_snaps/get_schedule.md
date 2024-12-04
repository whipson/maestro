# get_schedule returns a data.frame

    Code
      schedule
    Message
      
      -- Maestro Schedule with 7 pipelines:  
      * Not Run

# get_schedule works with DAG schedules

    Code
      get_schedule(schedule)[c("script_path", "pipe_name", "frequency", "tz", "skip",
        "log_level"), ]
    Output
      # A tibble: 6 x 9
        script_path pipe_name frequency start_time tz    skip  log_level
        <chr>       <chr>     <chr>     <dttm>     <chr> <lgl> <chr>    
      1 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      2 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      3 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      4 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      5 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      6 <NA>        <NA>      <NA>      NA         <NA>  NA    <NA>     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

