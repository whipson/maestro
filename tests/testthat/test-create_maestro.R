test_that("create_maestro creates a new maestro project", {
  withr::with_tempdir({
    create_maestro(path = ".", type = "R")
    expect_true(file.exists("orchestrator.R"))
    expect_true(dir.exists("pipelines"))
  })

  withr::with_tempdir({
    create_maestro(path = ".", type = "Quarto")
    expect_true(file.exists("orchestrator.qmd"))
    expect_true(dir.exists("pipelines"))
  })
})
