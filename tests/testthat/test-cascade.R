test_that("Labels cascade to direct children", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags label
      #' @maestroLabel maintainer will
      #' @maestroLabel domain finance
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "transform")
  expect_equal(nrow(transform_labels), 2)
  expect_true("maintainer" %in% transform_labels$label)
  expect_true("domain" %in% transform_labels$label)
  expect_equal(
    transform_labels$value[transform_labels$label == "maintainer"],
    "will"
  )
})

test_that("Labels cascade transitively to grandchildren", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags label
      #' @maestroLabel domain finance
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}

      #' @maestroInputs transform
      load <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  load_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "load")
  expect_equal(nrow(load_labels), 1)
  expect_equal(load_labels$label, "domain")
  expect_equal(load_labels$value, "finance")
})

test_that("Local label key wins over cascaded key", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags label
      #' @maestroLabel domain finance
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroLabel domain marketing
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "transform")
  expect_equal(nrow(transform_labels), 1)
  expect_equal(transform_labels$label, "domain")
  expect_equal(transform_labels$value, "marketing")
})

test_that("Flags cascade and union correctly", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags flags
      #' @maestroFlags critical etl
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroFlags cloud
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_flags <- get_flags(schedule) |>
    dplyr::filter(pipe_name == "transform") |>
    dplyr::pull(flag)
  expect_true("critical" %in% transform_flags)
  expect_true("etl" %in% transform_flags)
  expect_true("cloud" %in% transform_flags)
  expect_equal(length(transform_flags), 3)
})

test_that("Flags are not duplicated when already present locally", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags flags
      #' @maestroFlags critical etl
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroFlags critical
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_flags <- get_flags(schedule) |>
    dplyr::filter(pipe_name == "transform") |>
    dplyr::pull(flag)
  expect_equal(sum(transform_flags == "critical"), 1)
  expect_true("etl" %in% transform_flags)
})

test_that("loglevel cascades when downstream is at INFO default", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags loglevel
      #' @maestroLogLevel ERROR
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_log_level <- schedule$PipelineList$get_pipe_by_name("transform")$get_schedule()$log_level
  expect_equal(transform_log_level, "ERROR")
})

test_that("loglevel cascade does not overwrite an explicitly set downstream level", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags loglevel
      #' @maestroLogLevel ERROR
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroLogLevel WARN
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_log_level <- schedule$PipelineList$get_pipe_by_name("transform")$get_schedule()$log_level
  expect_equal(transform_log_level, "WARN")
})

test_that("Cascading INFO loglevel is a no-op", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags loglevel
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_log_level <- schedule$PipelineList$get_pipe_by_name("transform")$get_schedule()$log_level
  expect_equal(transform_log_level, "INFO")
})

test_that("Empty @maestroCascadeTags cascades all three tag types", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags
      #' @maestroLabel domain finance
      #' @maestroFlags critical
      #' @maestroLogLevel ERROR
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "transform")
  transform_flags <- get_flags(schedule) |>
    dplyr::filter(pipe_name == "transform") |>
    dplyr::pull(flag)
  transform_log_level <- schedule$PipelineList$get_pipe_by_name("transform")$get_schedule()$log_level

  expect_equal(transform_labels$label, "domain")
  expect_true("critical" %in% transform_flags)
  expect_equal(transform_log_level, "ERROR")
})

test_that("@maestroCascadeTags argument is case-insensitive", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags Label FLAGS
      #' @maestroLabel domain finance
      #' @maestroFlags critical
      extract <- function() {}

      #' @maestroInputs extract
      transform <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  transform_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "transform")
  transform_flags <- get_flags(schedule) |>
    dplyr::filter(pipe_name == "transform") |>
    dplyr::pull(flag)

  expect_equal(transform_labels$label, "domain")
  expect_true("critical" %in% transform_flags)
})

test_that("@maestroCascadeTags on a pipeline with no downstream causes no error", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags label
      #' @maestroLabel domain finance
      extract <- function() {}
      ",
      con = "pipelines/cascade.R"
    )
    expect_no_error(build_schedule(quiet = TRUE))
  })
})

test_that("Nearest ancestor label wins over farther ancestor", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags label
      #' @maestroLabel domain finance
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroCascadeTags label
      #' @maestroLabel domain marketing
      transform <- function(.input) {}

      #' @maestroInputs transform
      load <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    schedule <- build_schedule(quiet = TRUE)
  })

  load_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "load")
  expect_equal(nrow(load_labels), 1)
  expect_equal(load_labels$value[load_labels$label == "domain"], "marketing")
})

test_that("Unrecognised @maestroCascadeTags value warns and schedule still builds", {

  withr::with_tempdir({
    dir.create("pipelines")
    writeLines(
      "
      #' @maestroFrequency daily
      #' @maestroCascadeTags blah
      #' @maestroLabel domain finance
      extract <- function() {}

      #' @maestroInputs extract
      #' @maestroLabel domain marketing
      transform <- function(.input) {}

      #' @maestroInputs transform
      load <- function(.input) {}
      ",
      con = "pipelines/cascade.R"
    )
    expect_warning(
      schedule <- build_schedule(quiet = TRUE),
      "blah"
    )
  })

  # All three pipelines must still be present
  expect_equal(schedule$PipelineList$n_pipelines, 3)

  # Invalid cascade is ignored: load inherits no labels (transform has no @maestroCascadeTags)
  load_labels <- get_labels(schedule) |> dplyr::filter(pipe_name == "load")
  expect_equal(nrow(load_labels), 0)
})
