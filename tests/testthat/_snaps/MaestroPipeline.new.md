# Simple pipeline, no errors

    Code
      pipeline$get_status()
    Output
      # A tibble: 0 x 10
      # i 10 variables: pipe_name <chr>, script_path <chr>, invoked <lgl>,
      #   success <lgl>, pipeline_started <dttm>, pipeline_ended <dttm>,
      #   errors <int>, warnings <int>, messages <int>, lineage <chr>

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
      # A tibble: 0 x 10
      # i 10 variables: pipe_name <chr>, script_path <chr>, invoked <lgl>,
      #   success <lgl>, pipeline_started <dttm>, pipeline_ended <dttm>,
      #   errors <int>, warnings <int>, messages <int>, lineage <chr>

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
      1 TRUE    FALSE        1        0        0

# Pipeline with arguments are correctly passed

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 0 x 5
      # i 5 variables: invoked <lgl>, success <lgl>, errors <int>, warnings <int>,
      #   messages <int>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

