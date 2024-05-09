## code to prepare `example_schedule` dataset goes here

example_schedule <- build_schedule(test_path("test_pipelines_parse_all_good"))

usethis::use_data(example_schedule, overwrite = TRUE)
