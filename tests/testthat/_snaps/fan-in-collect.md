# Simple collect from distinct upstreams

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 3 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   

# Dynamic fan out followed by fan in

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 5 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    TRUE   
      5 TRUE    TRUE   

# Fan-out collect with iterateOver

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 5 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    TRUE   
      5 TRUE    TRUE   

