# Simple pipeline, no errors

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name  frequency start_time          tz    skip  log_level frequency_n
        <chr>      <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 get_mtcars 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()
    Output
      # A tibble: 1 x 8
        pipe_name  invoked success pipeline_started pipeline_ended errors
        <chr>      <lgl>   <lgl>   <dttm>           <dttm>          <int>
      1 get_mtcars FALSE   FALSE   NA               NA                  0
      # i 2 more variables: warnings <int>, messages <int>

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name  frequency start_time          tz    skip  log_level frequency_n
        <chr>      <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 get_mtcars 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

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
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name frequency start_time          tz    skip  log_level frequency_n
        <chr>     <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 pipe3     1 day     2024-01-01 00:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()
    Output
      # A tibble: 1 x 8
        pipe_name invoked success pipeline_started pipeline_ended errors
        <chr>     <lgl>   <lgl>   <dttm>           <dttm>          <int>
      1 pipe3     FALSE   FALSE   NA               NA                  0
      # i 2 more variables: warnings <int>, messages <int>

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name frequency start_time          tz    skip  log_level frequency_n
        <chr>     <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 pipe3     1 day     2024-01-01 00:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

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
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name frequency start_time          tz    skip  log_level frequency_n
        <chr>     <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 lm_mtcars 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    FALSE        2        0        0

# Pipeline with arguments are correctly passed

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name   frequency start_time          tz    skip  log_level frequency_n
        <chr>       <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 get_mtcars2 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 FALSE   FALSE        0        0        0

---

    Code
      pipeline$get_schedule()
    Output
      # A tibble: 1 x 8
        pipe_name   frequency start_time          tz    skip  log_level frequency_n
        <chr>       <chr>     <dttm>              <chr> <lgl> <chr>           <int>
      1 get_mtcars2 1 day     2024-03-01 09:00:00 UTC   FALSE INFO                1
      # i 1 more variable: frequency_unit <chr>

---

    Code
      pipeline$get_status()[c("invoked", "success", "errors", "warnings", "messages")]
    Output
      # A tibble: 1 x 5
        invoked success errors warnings messages
        <lgl>   <lgl>    <int>    <int>    <int>
      1 TRUE    TRUE         0        0        0

