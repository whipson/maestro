# Conditional pipes work with DAG pipelines via .input

    Code
      status$invoked
    Output
      [1] TRUE TRUE

---

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

