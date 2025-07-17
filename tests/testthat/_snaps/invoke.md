# invoke gives informative error message on failure

    Code
      schedule$get_status()[, c("invoked", "success")]
    Output
      # A tibble: 1 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    FALSE  

# invoke triggers DAG pipelines

    Code
      schedule$get_status()[, c("invoked", "success")]
    Output
      # A tibble: 2 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   

