# get_schedule returns a data.frame

    Code
      schedule
    Message
      
      -- Maestro Schedule with 7 pipelines:  
      * Not Run

# get_schedule works with DAG schedules

    Code
      get_schedule(schedule)[, c("script_path", "pipe_name", "frequency", "tz",
        "skip", "log_level")]
    Output
      # A tibble: 3 x 6
        script_path                     pipe_name frequency tz    skip  log_level
        <chr>                           <chr>     <chr>     <chr> <lgl> <chr>    
      1 test_pipelines_dags_good/dags.R primary   daily     UTC   FALSE INFO     
      2 test_pipelines_dags_good/dags.R trunk     daily     UTC   FALSE INFO     
      3 test_pipelines_dags_good/dags.R start     daily     UTC   FALSE INFO     

