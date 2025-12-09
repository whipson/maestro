# run_schedule timeliness checks - pipelines run when they're supposed to

    Code
      status$invoked
    Output
      [1] TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-25 10:30:00 UTC"

---

    Code
      status$invoked
    Output
      [1] TRUE TRUE TRUE TRUE TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-05-01 UTC" "2024-07-01 UTC" "2024-05-01 UTC" "2024-05-01 UTC"
      [5] "2024-05-01 UTC"

---

    Code
      status$invoked
    Output
      [1] TRUE TRUE TRUE TRUE TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-05 UTC" "2024-07-01 UTC" "2024-04-09 UTC" "2024-04-09 UTC"
      [5] "2024-04-05 UTC"

---

    Code
      status$invoked
    Output
      [1] TRUE TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-03-03 13:00:00 UTC" "2024-03-02 14:00:00 UTC"

# run_schedule timeliness checks - specifiers (e.g., hours, days, months)

    Code
      status$invoked
    Output
      [1] TRUE TRUE TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-04-08 00:00:00 UTC" "2024-04-01 04:00:00 UTC"
      [3] "2024-04-01 01:00:00 UTC"

---

    Code
      status$invoked
    Output
      [1] TRUE TRUE TRUE TRUE

---

    Code
      status$next_run
    Output
      [1] "2024-05-08 00:00:00 UTC" "2024-05-01 04:00:00 UTC"
      [3] "2024-05-01 01:00:00 UTC" "2024-10-01 00:00:00 UTC"

# maestroStartTime with HH:MM:SS runs on the expected time

    Code
      status$invoked
    Output
      [1] TRUE

# maestroPriority works as expected

    Code
      status$pipe_name
    Output
      character(0)

