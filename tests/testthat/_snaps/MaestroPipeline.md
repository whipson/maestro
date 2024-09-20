# Simple pipeline, no errors

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
      pipeline$get_status()
    Output
      # A tibble: 1 x 9
        pipe_name  script_path invoked success pipeline_started pipeline_ended
        <chr>      <chr>       <lgl>   <lgl>   <dttm>           <dttm>        
      1 get_mtcars test_pipel~ FALSE   FALSE   NA               NA            
      # i 3 more variables: errors <int>, warnings <int>, messages <int>

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

# Pipeline with warnings

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines_run_tw~ pipe3     1 day     2024-01-01 04:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()
    Output
      # A tibble: 1 x 9
        pipe_name script_path  invoked success pipeline_started pipeline_ended
        <chr>     <chr>        <lgl>   <lgl>   <dttm>           <dttm>        
      1 pipe3     test_pipeli~ FALSE   FALSE   NA               NA            
      # i 3 more variables: errors <int>, warnings <int>, messages <int>

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines_run_tw~ pipe3     1 day     2024-01-01 04:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        1        0

# Pipeline with errors

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines_run_so~ lm_mtcars 1 day     2024-03-01 13:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    FALSE        2        0        0

# Pipeline with arguments are correctly passed

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines_run_ar~ get_mtca~ 1 day     2024-03-01 13:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 FALSE   FALSE        0        0        0

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        script_path            pipe_name frequency start_time          skip  log_level
        <chr>                  <chr>     <chr>     <dttm>              <lgl> <chr>    
      1 test_pipelines_run_ar~ get_mtca~ 1 day     2024-03-01 13:00:00 FALSE INFO     
      # i 2 more variables: frequency_n <int>, frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

