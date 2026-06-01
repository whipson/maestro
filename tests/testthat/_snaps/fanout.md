# Simple fan out with no specified iterator

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 4 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    TRUE   

# Simple fan out into common downstream

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 7 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    TRUE   
      5 TRUE    TRUE   
      6 TRUE    TRUE   
      7 TRUE    TRUE   

# Simple fan out into common downstream and one error

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 6 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    FALSE  
      3 TRUE    TRUE   
      4 TRUE    TRUE   
      5 TRUE    TRUE   
      6 TRUE    TRUE   

# Use iterateOver to specify a particular iteration variable

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 4 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    TRUE   

# iterateOver is NULL

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 2 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    FALSE  

