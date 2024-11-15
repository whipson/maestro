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
        pipe_name  frequency start_time          tz    skip  log_level frequency_n
        <chr>      <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 get_mtcars 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

