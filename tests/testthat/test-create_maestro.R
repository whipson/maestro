test_that("create_maestro creates a new maestro project", {
  withr::with_tempdir({
    expect_message(create_maestro(path = ".", type = "R", overwrite = TRUE))
    expect_true(file.exists("orchestrator.R"))
    expect_true(dir.exists("pipelines"))
  })

  withr::with_tempdir({
    expect_message(create_maestro(path = ".", type = "Quarto", overwrite = TRUE))
    expect_true(file.exists("orchestrator.qmd"))
    expect_true(dir.exists("pipelines"))
  })
}) |>
  suppressMessages()

test_that("create_maestro aborts if directory already exists", {
  withr::with_tempdir({
    expect_error(
      create_maestro(path = "."),
      regexp = "Project directory already exists"
    )
  })

  # If overwrite = TRUE it will work
  withr::with_tempdir({
    expect_message(
      create_maestro(path = ".", overwrite = TRUE),
      regexp = "Overwriting existing project"
    )
  })
}) |>
  suppressMessages()
