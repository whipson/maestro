## code to prepare `schedule_table` dataset goes here

schedule_table <- data.frame(
  pipeline = c("pipe1.R", "pipe2.R", "pipe3.R"),
  start_time = c(Sys.time() + 400, Sys.time() - 1500, Sys.time() + 60000),
  frequency = c("daily", "hourly", "weekly"),
  interval = c(1, 3, 1)
)

usethis::use_data(schedule_table, overwrite = TRUE)
