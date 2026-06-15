# can get a single labeled pipeline

    Code
      schedule$get_labels()
    Output
      # A tibble: 1 x 3
        pipe_name label  value         
        <chr>     <chr>  <chr>         
      1 labelled  domain transportation

# can get a double labeled pipeline

    Code
      schedule$get_labels()
    Output
      # A tibble: 2 x 3
        pipe_name label  value         
        <chr>     <chr>  <chr>         
      1 labelled  domain transportation
      2 labelled  author will          

