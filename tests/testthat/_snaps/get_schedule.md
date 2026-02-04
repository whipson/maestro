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
      # A tibble: 11 x 6
         script_path                     pipe_name   frequency tz    skip  log_level
         <chr>                           <chr>       <chr>     <chr> <lgl> <chr>    
       1 test_pipelines_dags_good/dags.R with_inputs <NA>      <NA>  FALSE INFO     
       2 test_pipelines_dags_good/dags.R primary     daily     UTC   FALSE INFO     
       3 test_pipelines_dags_good/dags.R trunk       daily     UTC   FALSE INFO     
       4 test_pipelines_dags_good/dags.R branch1     <NA>      <NA>  FALSE INFO     
       5 test_pipelines_dags_good/dags.R branch2     <NA>      <NA>  FALSE INFO     
       6 test_pipelines_dags_good/dags.R subbranch1  <NA>      <NA>  FALSE INFO     
       7 test_pipelines_dags_good/dags.R subbranch2  <NA>      <NA>  FALSE INFO     
       8 test_pipelines_dags_good/dags.R start       daily     UTC   FALSE INFO     
       9 test_pipelines_dags_good/dags.R high_road   <NA>      <NA>  FALSE INFO     
      10 test_pipelines_dags_good/dags.R low_road    <NA>      <NA>  FALSE INFO     
      11 test_pipelines_dags_good/dags.R end         <NA>      <NA>  FALSE INFO     

