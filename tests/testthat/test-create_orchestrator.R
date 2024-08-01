test_that("create_orchestrator creates a new orchestrator", {
  withr::with_tempdir({
    create_orchestrator("orchestrator" ,open = FALSE)
    expect_true(file.exists("orchestrator.R"))
  }) |>
    expect_message()
})

test_that("create_orchestrator aborts if file already exists", {

  withr::with_tempdir({
    expect_error({
      dir <- tempdir()
      create_orchestrator(dir, open = FALSE)
      create_orchestrator(dir, open = FALSE)
    }, regexp = "already exists.")

    # Works if overwrite = TRUE
    expect_message(
      create_orchestrator(dir, open = FALSE, overwrite = TRUE),
      regexp = "Overwriting existing"
    )
  })
}) |>
  suppressMessages()
