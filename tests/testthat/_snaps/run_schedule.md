# run_schedule timeliness checks - pipelines run when they're supposed to

    Code
      status$invoked
    Output
      [1] FALSE FALSE FALSE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-26 09:00:00 UTC" "2024-04-25 13:00:00 UTC"
      [3] "2024-07-01 07:30:00 UTC" "2024-05-02 00:00:00 UTC"
      [5] "5000-12-12 10:15:00 UTC" "2024-04-25 10:30:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-05-01 UTC" "2024-05-01 UTC" "2024-07-01 UTC" "2024-05-01 UTC"
      [5] "5000-12-01 UTC" "2024-05-01 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE FALSE FALSE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-05 UTC" "2024-04-05 UTC" "2024-07-01 UTC" "2024-04-05 UTC"
      [5] "5000-12-13 UTC" "2024-04-05 UTC"

