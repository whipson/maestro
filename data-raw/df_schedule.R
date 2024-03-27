########################################
# Sample schedule data frame
########################################

df_schedule <- data.frame(
  pipeline_name = c("pipeline1.R", "pipeline2.R", "pipeline3.R", "pipeline4.R", "pipeline5.R"),
  start_datetime = as.POSIXct(c("2024-01-01 07:05:00 AST", "2024-03-01 08:10:00 AST", "2024-03-07 08:08:00 AST", "2024-02-29 14:25:00 AST", "2024-02-01 06:45:00 AST")),
  frequency = c("day", "hour", "hour", "day", "month"),
  interval = c(1, 1, 1, 1, 1)
)

usethis::use_data(df_schedule, overwrite = TRUE)
