# DAGs work as expected

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

