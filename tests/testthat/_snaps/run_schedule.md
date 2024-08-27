# run_schedule timeliness checks - pipelines run when they're supposed to

    Code
      status$invoked
    Output
      [1] FALSE FALSE FALSE FALSE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-26 09:00:00 UTC" "2024-04-25 13:00:00 UTC"
      [3] "2024-07-01 00:00:00 UTC" "2024-05-02 00:00:00 UTC"
      [5] "5000-12-12 10:15:30 UTC" "2024-05-02 00:00:00 UTC"
      [7] "2024-04-25 10:30:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-02 00:00:00 UTC" "2024-04-02 00:00:00 UTC"
      [3] "2024-07-01 00:00:00 UTC" "2024-04-04 00:00:00 UTC"
      [5] "5000-12-01 00:00:30 UTC" "2024-04-04 00:00:00 UTC"
      [7] "2024-04-01 01:00:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE FALSE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-02 00:00:00 UTC" "2024-04-02 00:00:00 UTC"
      [3] "2024-07-01 00:00:00 UTC" "2024-04-04 00:00:00 UTC"
      [5] "5000-12-13 00:00:30 UTC" "2024-04-04 00:00:00 UTC"
      [7] "2024-04-01 01:00:00 UTC"

# run_schedule timeliness checks - specifiers (e.g., hours, days, months)

    Code
      schedule
    Output
      # A tibble: 7 x 12
        script_path      pipe_name frequency start_time          skip  log_level hours
        <chr>            <chr>     <chr>     <dttm>              <lgl> <chr>     <lis>
      1 test_pipelines_~ specific~ daily     1970-01-01 00:00:00 FALSE INFO      <int>
      2 test_pipelines_~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <dbl>
      3 test_pipelines_~ specific~ biweekly  1970-01-01 00:00:00 FALSE INFO      <int>
      4 test_pipelines_~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <int>
      5 test_pipelines_~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <int>
      6 test_pipelines_~ specific~ monthly   1970-01-01 00:00:00 FALSE INFO      <int>
      7 test_pipelines_~ specific~ hourly    1970-01-01 00:00:00 FALSE INFO      <dbl>
      # i 5 more variables: months <list>, days_of_week <list>, days_of_month <list>,
      #   frequency_n <int>, frequency_unit <chr>

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE FALSE  TRUE FALSE FALSE FALSE

---

    Code
      status$next_run
    Output
      [1] "2024-04-08 00:00:00 UTC" "2024-04-01 04:00:00 UTC"
      [3] "2024-05-09 00:00:00 UTC" "2024-04-01 01:00:00 UTC"
      [5] "2024-04-06 00:00:00 UTC" "2024-05-01 00:00:00 UTC"
      [7] "2024-05-01 01:00:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE FALSE  TRUE FALSE  TRUE FALSE

---

    Code
      status$next_run
    Output
      [1] "2024-05-08 00:00:00 UTC" "2024-05-01 04:00:00 UTC"
      [3] "2024-05-09 00:00:00 UTC" "2024-05-01 01:00:00 UTC"
      [5] "2024-05-04 00:00:00 UTC" "2024-10-01 00:00:00 UTC"
      [7] "2024-05-01 01:00:00 UTC"

