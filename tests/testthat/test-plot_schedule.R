test_that("non-interactive schedule plot works", {
  skip_if_not_installed("ggplot2")

  p <- plot_schedule(
    example_schedule,
    interactive = FALSE
  )

  expect_s3_class(p, "ggplot")
})

test_that("interactive plot generates plotly", {
  skip_if_not_installed("ggplot2")
  skip_if_not_installed("plotly")

  p <- plot_schedule(
    example_schedule,
    interactive = TRUE
  )

  expect_s3_class(p, "plotly")
})
