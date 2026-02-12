# Multicore works

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

# Multicore DAGs work

    Code
      dag$get_network()
    Output
      # A tibble: 9 x 2
        from      to         
        <chr>     <chr>      
      1 primary   with_inputs
      2 trunk     branch1    
      3 trunk     branch2    
      4 branch1   subbranch1 
      5 branch2   subbranch2 
      6 start     high_road  
      7 start     low_road   
      8 high_road end        
      9 low_road  end        

