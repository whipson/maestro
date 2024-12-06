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
      [3] "2024-07-01 00:00:00 UTC" "2024-04-29 00:00:00 UTC"
      [5] "5000-12-12 10:15:00 UTC" "2024-04-29 00:00:00 UTC"
      [7] "2024-04-25 10:30:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-02 00:00:00 UTC" "2024-04-02 00:00:00 UTC"
      [3] "2024-07-01 00:00:00 UTC" "2024-04-08 00:00:00 UTC"
      [5] "5000-12-01 00:00:00 UTC" "2024-04-08 00:00:00 UTC"
      [7] "2024-04-01 01:00:00 UTC"

---

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-02 00:00:00 UTC" "2024-04-02 00:00:00 UTC"
      [3] "2024-07-01 00:00:00 UTC" "2024-04-08 00:00:00 UTC"
      [5] "5000-12-13 00:00:00 UTC" "2024-04-08 00:00:00 UTC"
      [7] "2024-04-01 01:00:00 UTC"

# run_schedule timeliness checks - specifiers (e.g., hours, days, months)

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE FALSE  TRUE FALSE FALSE FALSE

---

    Code
      status$next_run
    Output
      [1] "2024-04-08 00:00:00 UTC" "2024-04-01 04:00:00 UTC"
      [3] "2024-05-06 00:00:00 UTC" "2024-04-01 01:00:00 UTC"
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
      [3] "2024-05-06 00:00:00 UTC" "2024-05-01 01:00:00 UTC"
      [5] "2024-05-04 00:00:00 UTC" "2024-10-01 00:00:00 UTC"
      [7] "2024-05-01 01:00:00 UTC"

