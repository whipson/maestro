# get_flags works as expected

    Code
      flags_df
    Output
      # A tibble: 5 x 2
        pipe_name flag        
        <chr>     <chr>       
      1 p1        experimental
      2 p1        dev         
      3 p2        critical    
      4 p2        aviation    
      5 p3        critical    

# returns empty data.frame if there are no flags

    Code
      flags_df
    Output
      # A tibble: 0 x 2
      # i 2 variables: pipe_name <chr>, flag <chr>

