test_that("can deploy to posit connect", {

  withr::with_tempdir({
    create_orchestrator(path = "orchestrator", type = "Quarto", quiet = TRUE, open = FALSE)
    dir.create("pipelines")
    create_pipeline("window", quiet = TRUE, open = FALSE)
    deploy_posit_connect(write_manifest_args = list(envManagement = FALSE))
  })
})
