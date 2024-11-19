test_that("DAGs work as expected", {
  dag <- build_schedule(test_path("test_pipelines_dags_good"))
  run_schedule(dag)
  artifacts <- dag$get_artifacts()
  expect_true(all(dag$get_status()$success))
  expect_equal(artifacts$with_inputs, "input message is: hello")
  expect_equal(artifacts$branch2, 2)
  expect_equal(artifacts$subbranch1, 2)
  expect_equal(artifacts$subbranch2, 6)
}) |>
  suppressMessages()

test_that("Error messages for DAGs with nonexistent inputs/outputs", {
  expect_error({
    dag_bad <- build_schedule(test_path("test_pipelines_dags_bad"))
  }, regexp = "Pipeline")
})

test_that("Error in a DAG pipeline stops downstream computations", {
  dag_bad <- build_schedule(test_path("test_pipelines_dags_run_bad"))
  run_schedule(dag_bad)
  status <- get_status(dag_bad)
  expect_true(status$invoked[status$pipe_name == "get_num"])
  expect_true(!status$invoked[status$pipe_name == "multiply"])
}) |>
  suppressMessages()
