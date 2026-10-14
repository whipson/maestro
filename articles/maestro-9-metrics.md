# Custom Pipeline Metrics

Pipeline metrics are numeric values that track the performance of
executed pipelines. Any value that can be represented as a single number
can be a metric, but typical metrics are things like the number of rows
of a data.frame processed, data volume in bytes, number of API calls, or
number of attempts made on a task. Metrics are recorded without being
part of the pipeline’s return value, so they never get passed downstream
in a
[DAG](https://whipson.github.io/maestro/articles/maestro-4-directed-acyclic-graphs.md).

Other common metrics like execution time and success/fail are already
tracked by the orchestrator and are available via
[`get_status()`](https://whipson.github.io/maestro/reference/get_status.md)
and
[`get_schedule()`](https://whipson.github.io/maestro/reference/get_schedule.md),
so there’s no need to record those yourself.

## Recording Metrics

Custom metrics are recorded using the
[`update_metric()`](https://whipson.github.io/maestro/reference/update_metric.md)
function. It is called from within a pipeline function and takes the
name of the metric and a numeric value (a single, non-missing number).
Maestro automatically attributes the metric to the pipeline (and run)
that is currently executing.

``` r

#' ./pipelines/metric_example.R
#' @maestroFrequency 1 hour
extract_flights <- function() {

  # Pretends to fetch data from an API
  df <- data.frame(
    flight_id = 1:5,
    airline_code = c("UA", "AC", "AC", "AA", "DE"),
    departure_time = as.POSIXct("2026-10-14 12:00:00") + c(100, 450, 750, 1450, 1750)
  )

  update_metric("rows_read", nrow(df))
  update_metric("bytes_read", as.numeric(object.size(df)))

  df
}

#' @maestroInputs extract_flights
load_flights <- function(.input) {

  write.csv(.input, tempfile(fileext = ".csv"))

  update_metric("rows_written", nrow(.input))
}
```

After running the schedule,
[`get_metrics()`](https://whipson.github.io/maestro/reference/get_metrics.md)
returns a long data.frame (tibble) of every metric recorded: the
pipeline it came from (`pipe_name`), the run it was recorded in
(`run_id`), the `metric` name, and its numeric `value`.

``` r

library(maestro)

schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule,
  orch_frequency = "1 hour",
  quiet = TRUE
)

get_metrics(schedule)
```

     [38;5;246m# A tibble: 3 × 4 [39m
      pipe_name       run_id metric       value
       [3m [38;5;246m<chr> [39m [23m            [3m [38;5;246m<chr> [39m [23m   [3m [38;5;246m<chr> [39m [23m         [3m [38;5;246m<dbl> [39m [23m
     [38;5;250m1 [39m extract_flights SwlKLU rows_read        5
     [38;5;250m2 [39m extract_flights SwlKLU bytes_read     [4m1 [24m648
     [38;5;250m3 [39m load_flights    exomb9 rows_written     5

Note that each pipeline gets its own `run_id`, even within a DAG. Since
the result is a data.frame, it’s straightforward to summarise further or
write out to a database or file.

Metrics are only recorded when a pipeline is executed by
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).
Calling
[`update_metric()`](https://whipson.github.io/maestro/reference/update_metric.md)
while developing or testing a pipeline function interactively is
harmless: it emits an informational message and does nothing.

## Metrics Are Per Execution

Metrics belong to a single execution of a pipeline. Each time a pipeline
runs it gets a new `run_id`, and its metrics are stored separately from
those of earlier runs. Within one execution, calling
[`update_metric()`](https://whipson.github.io/maestro/reference/update_metric.md)
again with the same name overwrites the earlier value (the last write
wins).

Running the same schedule a second time shows this. The metrics from
both runs are retained and distinguished by `run_id`.

``` r

status <- run_schedule(
  schedule,
  orch_frequency = "1 hour",
  quiet = TRUE
)

get_metrics(schedule)
```

     [38;5;246m# A tibble: 6 × 4 [39m
      pipe_name       run_id metric       value
       [3m [38;5;246m<chr> [39m [23m            [3m [38;5;246m<chr> [39m [23m   [3m [38;5;246m<chr> [39m [23m         [3m [38;5;246m<dbl> [39m [23m
     [38;5;250m1 [39m extract_flights SwlKLU rows_read        5
     [38;5;250m2 [39m extract_flights SwlKLU bytes_read     [4m1 [24m648
     [38;5;250m3 [39m extract_flights HfdVHI rows_read        5
     [38;5;250m4 [39m extract_flights HfdVHI bytes_read     [4m1 [24m648
     [38;5;250m5 [39m load_flights    exomb9 rows_written     5
     [38;5;250m6 [39m load_flights    fivjF0 rows_written     5

## Accumulating with `increment = TRUE`

Sometimes a metric is built up over the course of a pipeline rather than
computed once, such as counting API calls inside a loop or the number of
attempts on a task. Setting `increment = TRUE` adds `value` to the
metric’s current value instead of overwriting it. If the metric hasn’t
been set yet in the current run, the first call simply sets it. A
negative `value` decrements.

In this example, a pipeline pages through an API and retries a flaky
request. Both the number of API calls and the number of attempts
accumulate.

``` r

#' ./pipelines/metric_increment.R
#' @maestroFrequency 1 day
fetch_paginated <- function() {

  pages <- 1:3
  results <- list()

  for (page in pages) {
    attempts <- 0
    repeat {
      attempts <- attempts + 1
      update_metric("attempts", 1, increment = TRUE)

      # Pretends to call an API that sometimes fails
      ok <- runif(1) > 0.5
      if (ok || attempts >= 3) break
    }

    update_metric("api_calls", 1, increment = TRUE)
    results[[page]] <- data.frame(page = page, value = rnorm(10))
  }

  df <- do.call(rbind, results)

  # Overwriting (default) is fine for a one-off value
  update_metric("rows_read", nrow(df))

  df
}
```

``` r

set.seed(2718)

schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule,
  orch_frequency = "1 day",
  quiet = TRUE
)

get_metrics(schedule)
```

     [38;5;246m# A tibble: 3 × 4 [39m
      pipe_name       run_id metric    value
       [3m [38;5;246m<chr> [39m [23m            [3m [38;5;246m<chr> [39m [23m   [3m [38;5;246m<chr> [39m [23m      [3m [38;5;246m<dbl> [39m [23m
     [38;5;250m1 [39m fetch_paginated SYyFTx attempts      4
     [38;5;250m2 [39m fetch_paginated SYyFTx api_calls     3
     [38;5;250m3 [39m fetch_paginated SYyFTx rows_read    30

Each metric has a single value per pipeline run: `api_calls` ends at 3
(one per page) while `attempts` is at least 3, depending on how many
retries were needed.
