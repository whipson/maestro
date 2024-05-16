library(maestro)

schedule <- build_schedule("sample_project/pipelines/")

run_schedule(
  schedule,
  run_all = TRUE
)
