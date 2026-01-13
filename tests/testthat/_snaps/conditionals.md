# Conditional pipes work with DAG pipelines via .input

    Code
      status$invoked
    Output
      [1] TRUE TRUE

---

    Code
      status$invoked
    Output
      [1]  TRUE FALSE

---

    Code
      lineage[, c("from_name", "to_name")]
    Output
      # A tibble: 1 x 2
        from_name to_name
        <chr>     <chr>  
      1 p1        <NA>   

---

    Code
      status$invoked
    Output
      [1]  TRUE FALSE

# DAGs with a conditional pipe in the middle by default halt further execution of the DAG

    Code
      status$invoked
    Output
      [1]  TRUE FALSE FALSE

# Conditional pipes work using resources

    Code
      status$invoked
    Output
      [1]  TRUE FALSE

# Conditions with errors are handled

    Code
      status$success
    Output
      [1] NA

---

    Code
      status$invoked
    Output
      [1] TRUE

---

    Code
      last_run_errors()
    Output
      $p1
      <simpleError in rlang::eval_bare(e, env): Error evaluating condition: oh no>
      

# Conditions that don't return a single boolean are handled

    Code
      status$success
    Output
      [1] NA

---

    Code
      status$invoked
    Output
      [1] TRUE

---

    Code
      last_run_errors()
    Output
      $p1
      <simpleError: Error evaluating condition: `c(1, 2)` did not return a single boolean.>
      

# Empty maestroRunIf is ignored

    Code
      status$success
    Output
      [1] TRUE

---

    Code
      status$invoked
    Output
      [1] TRUE

# Branching pipelines execute with conditionals

    Code
      status$invoked
    Output
      [1]  TRUE  TRUE FALSE

