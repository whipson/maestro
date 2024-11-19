test_that("DAGs work as expected", {
  dag <- build_schedule(test_path("test_pipelines_dags_good"))
  run_schedule(dag)
  artifacts <- dag$get_artifacts()
  expect_equal(artifacts$with_inputs, "input message is: hello")
  expect_equal(artifacts$branch2, 2)
  expect_equal(artifacts$subbranch1, 2)
  expect_equal(artifacts$subbranch2, 6)
}) |>
  suppressMessages()

