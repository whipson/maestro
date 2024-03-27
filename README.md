
<!-- README.md is generated from README.Rmd. Please edit that file -->

# baton

<!-- badges: start -->
<!-- badges: end -->

`baton` is a lightweight and easy-to-use framework for creating and
orchestrating data pipelines in R. No additional orchestration tools are
needed.

In `baton` there are pipelines (functions) that can be scheduled and
configured using `roxygen2` tags - these are special comment above each
function. There is also an orchestrator script responsible for executing
the scheduled pipelines (optionally in parallel).

## Pre-release Disclaimer

`baton` is in early development and its API may undergo changes without
notice or deprecation. We encourage people to try it out in real world
scenarios, but we do not yet advise using it in critical production
environments until it has been thoroughly tested and the API has
stabilized.

## Installation

`baton` is currently pre-release and not available yet on CRAN. It can
be installed from Github directly like so:

``` r
devtools::install("https://github.com/whipson/baton")
```

## Project Setup

A `baton` project needs at least two components:

1.  A collection of R pipelines (functions) that you want to schedule
2.  A single orchestrator script that kicks off the scripts when they’re
    scheduled to run

Let’s look at each of these in more detail.

### Pipelines

A pipeline is task we want to run. This task may involve retrieving data
from a source, performing cleaning and computation on the data, then
sending it to a destination. `baton` is not concerned with what your
pipeline does, but rather *when* you want to run it. Here’s a simple
pipeline in `baton`:

``` r
#' @batonFrequency daily
#' @batonInterval 1
#' @batonStartTime 2024-03-25 12:30:00
my_etl <- function() {
  
  # Extract data from random user generator
  raw_data <- httr2::request("https://randomuser.me/api/") |> 
    httr2::req_perform() |> 
    httr2::resp_body_json(simplifyVector = TRUE)
  
  # Transform - get results and clean the names
  transformed <- raw_data$results |> 
    janitor::clean_names()
  
  # Load - write to a location
  write.csv(transformed, file = paste0("random_user_", Sys.Date(), ".csv"))
}
```

What makes this a `baton` pipeline is the use of special *roxygen*-style
comments above the function definition. `#' @batonFrequency daily`
indicates that this function should execute at a daily frequency,
`#' @batonInterval 1` tells us it should be every day, and
`#' @batonStartTime 2024-03-25 12:30:00` denotes the first time it
should run. In other words, we’d expect it to run every day at 12:30
starting the 25th of March 2024. But this pipeline won’t run at all
unless there is another process *telling* it to run. That is the job of
the orchestrator.

### Orchestrator

The orchestrator is a script that checks the schedules of all the
functions in a \`baton\` project and executes them if they’re due to go.
The orchestrator also handles global execution tasks such as collecting
logs and managing shared resources like database connections, global
objects, and custom functions.

You have the option of using Quarto, RMarkdown, or a straight-up R
script for the orchestrator, but the former two have some advantages
with respect to deployment on Posit Connect.

A simple orchestrator looks like this:

``` r
# Look through the pipelines directory for baton pipelines to create a schedule
schedule_table <- build_schedule(pipeline_dir = "pipelines")

# Checks which pipelines are due to run and then executes them (optionally in parallel)
run_schedule(schedule_table, cores = 4)

# Optionally get the logs from all the pipelines
logs <- latest_run_logs()
```

The function `build_schedule()` scours through all the
pipelines in the provided directory and builds a schedule. Then
`run_schedule()` checks each pipeline’s scheduled time against the
system time within some margin of rounding[^1] and calls those pipelines
to run. `baton` also includes several helper functions pertaining to
observability and monitoring, such as `latest_run_logs()` to get the
full set of logs across all pipelines that ran.

## Deployment

More to come

[^1]: Depending on the frequency and start time of pipeline and the
    frequency and start time of the orchestrator, this may be a key
    consideration. \`baton\` does not look for an exact match of the
    scheduled time with the current time because then it would almost
    never run. Rather, it rounds the times to within a unit compatible
    with the particular pipeline frequency.
