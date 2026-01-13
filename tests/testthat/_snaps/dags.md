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

# Even if a downstream pipeline is 'scheduled' it doesn't run unless the upstream component does

    Code
      schedule$get_status()$invoked
    Output
      [1] FALSE FALSE

---

    Code
      schedule$get_status()$invoked
    Output
      [1] FALSE FALSE FALSE

# Even if a downstream pipeline is 'scheduled' it runs if the upstream component does

    Code
      schedule$get_status()$invoked
    Output
      [1] TRUE TRUE

---

    Code
      schedule$get_status()$invoked
    Output
      [1] TRUE TRUE TRUE

# Branching DAG pipelines with an error in one branch continue on second branch

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 4 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    FALSE  
      4 TRUE    TRUE   

# Branching DAG pipelines both ending in errors accurately outputs errors

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 4 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    FALSE  
      4 TRUE    FALSE  

---

    Code
      last_run_errors()
    Output
      $end1
      [1] "oops"
      
      $end2
      [1] "oh dear"
      

# Branching and merging DAG pipelines have separate status entries for each lineage

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

---

    Code
      unname(unlist(get_artifacts(schedule)))
    Output
      [1]  4 12  8 24 16

# Branching and merging DAG pipelines use vectors for multiple errors

    Code
      status[, c("invoked", "success")]
    Output
      # A tibble: 5 x 2
        invoked success
        <lgl>   <lgl>  
      1 TRUE    TRUE   
      2 TRUE    TRUE   
      3 TRUE    TRUE   
      4 TRUE    FALSE  
      5 TRUE    FALSE  

---

    Code
      unname(unlist(get_artifacts(schedule)))
    Output
      [1]  4 12  8

---

    Code
      last_run_errors()
    Output
      $end
      [1] "oops" "oops"
      

---

    Code
      lineage
    Output
      # A tibble: 6 x 2
        from_name to_name
        <chr>     <chr>  
      1 start     mid1   
      2 start     mid2   
      3 mid1      end    
      4 mid2      end    
      5 end       <NA>   
      6 end       <NA>   

# Two separate DAGs have separate lineages

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

---

    Code
      lineage
    Output
      # A tibble: 4 x 2
        from_name to_name
        <chr>     <chr>  
      1 start2    end2   
      2 start     end    
      3 end       <NA>   
      4 end2      <NA>   

