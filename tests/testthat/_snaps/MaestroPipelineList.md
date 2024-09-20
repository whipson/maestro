# Simple pipeline list, no errors

    Code
      pipeline_list
    Message
      
      -- Maestro Pipelines List with 1 pipeline 

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines/test_p~ get_mtca~ 1 day     2024-03-01 13:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

