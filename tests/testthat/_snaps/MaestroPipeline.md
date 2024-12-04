# Simple pipeline, no errors

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
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

# Pipeline with warnings

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
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        1        0

# Pipeline with errors

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    FALSE        2        0        0

# Pipeline with arguments are correctly passed

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 FALSE   FALSE        0        0        0

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

