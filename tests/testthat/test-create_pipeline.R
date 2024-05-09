test_that("create_pipeline creates a new pipeline", {
  withr::with_tempdir({
    create_pipeline("new_pipe", open = FALSE)
    expect_true(file.exists("pipelines/new_pipe.R"))
  }) |>
    expect_message()
})