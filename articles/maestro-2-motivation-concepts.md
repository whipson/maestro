# Motivation and Concepts

## What is maestro?

`maestro` is an R package for creating and orchestrating many data
pipelines in R. If you have several batch jobs/pipelines that you want
to schedule and monitor from within a single R project, then `maestro`
is for you. All you do is *decorate* R functions with special `roxygen2`
tags and then execute an orchestrator script.

The diagram below imagines a weather-based maestro project with four
distinct pipeline scripts (one of which has a dependency on an upstream
pipeline). In this scenario, every 15 minutes the orchestrator runs and
evaluates which pipelines are scheduled to run; then it kicks off those
pipelines.

![](data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNzAwIiBoZWlnaHQ9IjQxMCIgdmlld2JveD0iMCAwIDcwMCA0MTAiPjxkZWZzPjxtYXJrZXIgaWQ9Im1vLWFyci1vZmYiIG1hcmtlcndpZHRoPSI3IiBtYXJrZXJoZWlnaHQ9IjYiIHJlZng9IjYuNSIgcmVmeT0iMyIgb3JpZW50PSJhdXRvIiBtYXJrZXJ1bml0cz0ic3Ryb2tlV2lkdGgiPjxwYXRoIGQ9Ik0wLDAuNSBMNywzIEwwLDUuNSBaIiBmaWxsPSIjZThkZGY1IiAvPjwvbWFya2VyPjxtYXJrZXIgaWQ9Im1vLWFyci1vbiIgbWFya2Vyd2lkdGg9IjciIG1hcmtlcmhlaWdodD0iNiIgcmVmeD0iNi41IiByZWZ5PSIzIiBvcmllbnQ9ImF1dG8iIG1hcmtlcnVuaXRzPSJzdHJva2VXaWR0aCI+PHBhdGggZD0iTTAsMC41IEw3LDMgTDAsNS41IFoiIGZpbGw9IiM5MDEyQzciIC8+PC9tYXJrZXI+PGZpbHRlciBpZD0ibW8tY2FyZC1zaGFkb3ciIHg9Ii0xMCUiIHk9Ii0xNSUiIHdpZHRoPSIxMjAlIiBoZWlnaHQ9IjE0MCUiPjxmZWRyb3BzaGFkb3cgZHg9IjAiIGR5PSIyIiBzdGRkZXZpYXRpb249IjQiIGZsb29kLWNvbG9yPSJyZ2JhKDEwMCw1MCwxNDAsMC4xMCkiPjwvZmVkcm9wc2hhZG93PjwvZmlsdGVyPjxwYXR0ZXJuIGlkPSJtby1wdHMiIHg9IjAiIHk9IjAiIHdpZHRoPSIyNiIgaGVpZ2h0PSIyNiIgcGF0dGVybnVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PGNpcmNsZSBjeD0iMTMiIGN5PSIxMyIgcj0iMS4xIiBmaWxsPSIjZjBlOGY4Ij48L2NpcmNsZT48L3BhdHRlcm4+PC9kZWZzPjxyZWN0IHdpZHRoPSI3MDAiIGhlaWdodD0iNDEwIiByeD0iMTYiIGZpbGw9IiNmYWY3ZmQiIC8+PHJlY3Qgd2lkdGg9IjcwMCIgaGVpZ2h0PSI0MTAiIHJ4PSIxNiIgZmlsbD0idXJsKCNtby1wdHMpIiAvPjx0ZXh0IGNsYXNzPSJ3b3JkbWFyayIgeD0iMzUwIiB5PSIyNiIgdGV4dC1hbmNob3I9Im1pZGRsZSI+TUFFU1RSTzwvdGV4dD48bGluZSBpZD0ibW8tdGxzMCIgY2xhc3M9InRsLXNlZ21lbnQiIHgxPSIxNTgiIHkxPSI1NiIgeDI9IjI5OCIgeTI9IjU2Ij48L2xpbmU+PGxpbmUgaWQ9Im1vLXRsczEiIGNsYXNzPSJ0bC1zZWdtZW50IiB4MT0iMzE4IiB5MT0iNTYiIHgyPSI0NTIiIHkyPSI1NiI+PC9saW5lPjxsaW5lIGlkPSJtby10bHMyIiBjbGFzcz0idGwtc2VnbWVudCIgeDE9IjQ3MiIgeTE9IjU2IiB4Mj0iNTkyIiB5Mj0iNTYiPjwvbGluZT48Y2lyY2xlIGlkPSJtby10bjAiIGNsYXNzPSJ0bC1ub2RlIiBjeD0iMTQ3IiBjeT0iNTYiIHI9IjExIj48L2NpcmNsZT48Y2lyY2xlIGlkPSJtby10bjEiIGNsYXNzPSJ0bC1ub2RlIiBjeD0iMzA4IiBjeT0iNTYiIHI9IjExIj48L2NpcmNsZT48Y2lyY2xlIGlkPSJtby10bjIiIGNsYXNzPSJ0bC1ub2RlIiBjeD0iNDYyIiBjeT0iNTYiIHI9IjExIj48L2NpcmNsZT48Y2lyY2xlIGlkPSJtby10bjMiIGNsYXNzPSJ0bC1ub2RlIiBjeD0iNjAzIiBjeT0iNTYiIHI9IjExIj48L2NpcmNsZT48dGV4dCBpZD0ibW8tdGwwIiBjbGFzcz0idGwtbGFiZWwiIHg9IjE0NyIgeT0iNzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiPjowMDwvdGV4dD48dGV4dCBpZD0ibW8tdGwxIiBjbGFzcz0idGwtbGFiZWwiIHg9IjMwOCIgeT0iNzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiPjoxNTwvdGV4dD48dGV4dCBpZD0ibW8tdGwyIiBjbGFzcz0idGwtbGFiZWwiIHg9IjQ2MiIgeT0iNzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiPjozMDwvdGV4dD48dGV4dCBpZD0ibW8tdGwzIiBjbGFzcz0idGwtbGFiZWwiIHg9IjYwMyIgeT0iNzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiPjo0NTwvdGV4dD48dGV4dCBjbGFzcz0idGwtbGFiZWwiIHg9IjIyMiIgeT0iNzgiIHRleHQtYW5jaG9yPSJtaWRkbGUiIG9wYWNpdHk9IjAuNyI+MTVtPC90ZXh0Pjx0ZXh0IGNsYXNzPSJ0bC1sYWJlbCIgeD0iMzg1IiB5PSI3OCIgdGV4dC1hbmNob3I9Im1pZGRsZSIgb3BhY2l0eT0iMC43Ij4xNW08L3RleHQ+PHRleHQgY2xhc3M9InRsLWxhYmVsIiB4PSI1MjciIHk9Ijc4IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBvcGFjaXR5PSIwLjciPjE1bTwvdGV4dD48Y2lyY2xlIGlkPSJtby1vcjEiIGNsYXNzPSJvcmNoLXJpbmciIGN4PSIxMTIiIGN5PSIyNDYiIHI9IjUyIj48L2NpcmNsZT48Y2lyY2xlIGlkPSJtby1vcjIiIGNsYXNzPSJvcmNoLXJpbmciIGN4PSIxMTIiIGN5PSIyNDYiIHI9IjYwIj48L2NpcmNsZT48Y2lyY2xlIGlkPSJtby1vcmNoLWJvZHkiIGN4PSIxMTIiIGN5PSIyNDYiIHI9IjQ0IiBmaWxsPSIjOTAxMkM3IiBzdHlsZT0iZmlsdGVyOiBkcm9wLXNoYWRvdygwIDNweCAxMnB4IHJnYmEoMTQ0LDE4LDE5OSwwLjI4KSk7IHRyYW5zaXRpb246IGZpbHRlciAwLjJzOyI+PC9jaXJjbGU+PGNpcmNsZSBjbGFzcz0iY2xvY2stZmFjZSIgY3g9IjExMiIgY3k9IjI0NiIgcj0iMjAiPjwvY2lyY2xlPjxsaW5lIGNsYXNzPSJjbG9jay10aWNrIiB4MT0iMTEyIiB5MT0iMjI4IiB4Mj0iMTEyIiB5Mj0iMjMxIj48L2xpbmU+PGxpbmUgY2xhc3M9ImNsb2NrLXRpY2siIHgxPSIxMzAiIHkxPSIyNDYiIHgyPSIxMjciIHkyPSIyNDYiPjwvbGluZT48bGluZSBjbGFzcz0iY2xvY2stdGljayIgeDE9IjExMiIgeTE9IjI2NCIgeDI9IjExMiIgeTI9IjI2MSI+PC9saW5lPjxsaW5lIGNsYXNzPSJjbG9jay10aWNrIiB4MT0iOTQiIHkxPSIyNDYiIHgyPSI5NyIgeTI9IjI0NiI+PC9saW5lPjxsaW5lIGlkPSJtby1vcmNoLW1pbiIgY2xhc3M9ImNsb2NrLWhhbmQiIHgxPSIxMTIiIHkxPSIyNDYiIHgyPSIxMTIiIHkyPSIyMjgiPjwvbGluZT48Y2lyY2xlIGNsYXNzPSJjbG9jay1kb3QiIGN4PSIxMTIiIGN5PSIyNDYiIHI9IjIuNSI+PC9jaXJjbGU+PHRleHQgY2xhc3M9Im9yY2gtbGFiZWwiIHg9IjExMiIgeT0iMzA0IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5PUkNIRVNUUkFUT1I8L3RleHQ+PGxpbmUgaWQ9Im1vLWJyYSIgY2xhc3M9ImJyYW5jaCIgeDE9IjE1MSIgeTE9IjIyNiIgeDI9IjI5MSIgeTI9IjE1OCI+PC9saW5lPjxsaW5lIGlkPSJtby1icmIiIGNsYXNzPSJicmFuY2giIHgxPSIxNTYiIHkxPSIyNDYiIHgyPSIyOTEiIHkyPSIyNDYiPjwvbGluZT48bGluZSBpZD0ibW8tYnJjIiBjbGFzcz0iYnJhbmNoIiB4MT0iMTUxIiB5MT0iMjY3IiB4Mj0iMjkxIiB5Mj0iMzM0Ij48L2xpbmU+PGxpbmUgaWQ9Im1vLWJyZCIgY2xhc3M9ImJyYW5jaCIgeDE9IjQxNCIgeTE9IjI0NiIgeDI9IjQ3MSIgeTI9IjI0NiI+PC9saW5lPjxyZWN0IGlkPSJtby10YSIgY2xhc3M9Im5vZGUtYm94IiB4PSIyOTQiIHk9IjExOCIgd2lkdGg9IjEyMCIgaGVpZ2h0PSI3MiIgcng9IjEyIiBmaWx0ZXI9InVybCgjbW8tY2FyZC1zaGFkb3cpIiAvPjxyZWN0IGlkPSJtby10YS1iYWRnZSIgY2xhc3M9ImJhZGdlLWJnIiB4PSIzMDAiIHk9IjEyNCIgd2lkdGg9IjEwOCIgaGVpZ2h0PSIyOCIgcng9IjciIC8+PHRleHQgaWQ9Im1vLXRhLWJhZGdlLXQiIGNsYXNzPSJiYWRnZS10ZXh0IiB4PSIzNTQiIHk9IjEzNSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+PHRzcGFuIHg9IjM1NCIgZHk9IjAiPkBtYWVzdHJvRnJlcXVlbmN5PC90c3Bhbj48dHNwYW4geD0iMzU0IiBkeT0iMTIiPjE1IG1pbnV0ZXM8L3RzcGFuPjwvdGV4dD48dGV4dCBpZD0ibW8tdGEtbmFtZSIgY2xhc3M9Im5vZGUtbmFtZSIgeD0iMzU0IiB5PSIxNzQiIHRleHQtYW5jaG9yPSJtaWRkbGUiPnRlbXBfcmVhZGluZ3M8L3RleHQ+PHJlY3QgaWQ9Im1vLXRiIiBjbGFzcz0ibm9kZS1ib3giIHg9IjI5NCIgeT0iMjEwIiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjcyIiByeD0iMTIiIGZpbHRlcj0idXJsKCNtby1jYXJkLXNoYWRvdykiIC8+PHJlY3QgaWQ9Im1vLXRiLWJhZGdlIiBjbGFzcz0iYmFkZ2UtYmciIHg9IjMwMCIgeT0iMjE2IiB3aWR0aD0iMTA4IiBoZWlnaHQ9IjI4IiByeD0iNyIgLz48dGV4dCBpZD0ibW8tdGItYmFkZ2UtdCIgY2xhc3M9ImJhZGdlLXRleHQiIHg9IjM1NCIgeT0iMjI3IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj48dHNwYW4geD0iMzU0IiBkeT0iMCI+QG1hZXN0cm9GcmVxdWVuY3k8L3RzcGFuPjx0c3BhbiB4PSIzNTQiIGR5PSIxMiI+MzAgbWludXRlczwvdHNwYW4+PC90ZXh0Pjx0ZXh0IGlkPSJtby10Yi1uYW1lIiBjbGFzcz0ibm9kZS1uYW1lIiB4PSIzNTQiIHk9IjI2NyIgdGV4dC1hbmNob3I9Im1pZGRsZSI+d2VhdGhlcl9idWxsZXRpbnM8L3RleHQ+PHJlY3QgaWQ9Im1vLXRjIiBjbGFzcz0ibm9kZS1ib3giIHg9IjI5NCIgeT0iMzA0IiB3aWR0aD0iMTIwIiBoZWlnaHQ9IjcyIiByeD0iMTIiIGZpbHRlcj0idXJsKCNtby1jYXJkLXNoYWRvdykiIC8+PHJlY3QgaWQ9Im1vLXRjLWJhZGdlIiBjbGFzcz0iYmFkZ2UtYmciIHg9IjMwMCIgeT0iMzEwIiB3aWR0aD0iMTA4IiBoZWlnaHQ9IjI4IiByeD0iNyIgLz48dGV4dCBpZD0ibW8tdGMtYmFkZ2UtdCIgY2xhc3M9ImJhZGdlLXRleHQiIHg9IjM1NCIgeT0iMzIxIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj48dHNwYW4geD0iMzU0IiBkeT0iMCI+QG1hZXN0cm9GcmVxdWVuY3k8L3RzcGFuPjx0c3BhbiB4PSIzNTQiIGR5PSIxMiI+MSBob3VyPC90c3Bhbj48L3RleHQ+PHRleHQgaWQ9Im1vLXRjLW5hbWUiIGNsYXNzPSJub2RlLW5hbWUiIHg9IjM1NCIgeT0iMzYxIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5zYXRlbGxpdGVfaW1hZ2VyeTwvdGV4dD48cmVjdCBpZD0ibW8tdGQiIGNsYXNzPSJkb3duLWJveCIgeD0iNDcyIiB5PSIyMTgiIHdpZHRoPSIxMDQiIGhlaWdodD0iNTYiIHJ4PSIxMiIgZmlsdGVyPSJ1cmwoI21vLWNhcmQtc2hhZG93KSIgLz48cmVjdCBpZD0ibW8tdGQtYmFkZ2UiIGNsYXNzPSJiYWRnZS1iZyIgeD0iNDc4IiB5PSIyMjQiIHdpZHRoPSI5MiIgaGVpZ2h0PSIyNiIgcng9IjciIC8+PHRleHQgaWQ9Im1vLXRkLWJhZGdlLXQiIGNsYXNzPSJiYWRnZS10ZXh0IiB4PSI1MjQiIHk9IjIzNCIgdGV4dC1hbmNob3I9Im1pZGRsZSI+PHRzcGFuIHg9IjUyNCIgZHk9IjAiPkBtYWVzdHJvSW5wdXRzPC90c3Bhbj48dHNwYW4geD0iNTI0IiBkeT0iMTIiPndlYXRoZXJfYnVsbGV0aW5zPC90c3Bhbj48L3RleHQ+PHRleHQgaWQ9Im1vLXRkLW5hbWUiIGNsYXNzPSJub2RlLW5hbWUiIHg9IjUyNCIgeT0iMjYyIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5zZW5kX2FsZXJ0PC90ZXh0Pjwvc3ZnPg==)

## Why do I need maestro?

Running data pipelines is an essential component of data engineering. It
is not unusual to have dozens of pipelines that need to run at different
frequencies, and when you go to deploy these pipelines scheduling and
monitoring them quickly becomes unwieldy. Perhaps you’ve considered
moving to heftier orchestration suites such as Airflow, Dagster, and
others which require learning entirely new skills and pose their own
challenges with deployment. `maestro` allows you to orchestrate your
pipelines entirely in R. All you then need is an environment to deploy
your `maestro` project.

## Pipelines

A pipeline is some process that takes raw data (often from an external
source) and moves it somewhere else often transforming it along the way.
Think of a pipeline as a factory assembly line where data is the raw
material. As this data travels along the pipeline, it undergoes various
transformations—such as cleaning, aggregation, and analysis—making it
increasingly refined and valuable. The refined product is then stored in
a new location where it can be used either by an end consumer or another
pipeline. The prototypical type of pipeline in data engineering is ETL
(**E**xtract, **T**ransform, **L**oad), where data is extracted from a
source, transformed, then loaded into storage.

### Scheduled Batch Processing

The pipeline needs to run regularly and automatically to process new
data. Most analytic workloads undergo batch processing - the processing
of data in discrete timed batches. In scheduled batch processing, you as
the engineer decide how often you want your pipeline to run (every day
at 12:00?, every hour on the 15th minute?).

In `maestro` a pipeline is an R function with `roxygen2` comments for
scheduling and configuration:

``` r
#' my_pipe maestro pipeline
#'
#' @maestroFrequency 1 day
#' @maestroStartTime 2024-05-24

my_pipe <- function() {

  random_data <- data.frame(
    letters = sample(letters, 10),
    numbers = sample.int(10)
  )
  
  write.csv(random_data, file = tempfile())
}
```

## Orchestrator

An orchestrator is a process that triggers pipelines to run. Think of it
as the factory manager who turns on various assembly lines as needed. It
also monitors all the pipelines to ensure smooth operation. Just like
the factory manager, the orchestrator operates in “shifts” and so needs
to be scheduled to perform it’s job too.

### Rounded Scheduling

Importantly, `maestro` needs to know how often you’re going to run the
orchestrator. Unlike most orchestration tools out there, `maestro` isn’t
intended to be continuously running, which saves you on compute
resources. But this means that pipelines won’t necessarily run *exactly*
when they’re scheduled to. This is a concept we call *rounded
scheduling.*

Let’s say we have a pipeline scheduled to run hourly on the 02 minute
mark (e.g., 01:02, 02:02, etc.), and our orchestrator runs every hour on
the 00 minute. When the orchestrator runs, it’ll be slightly before the
pipeline scheduled time, but it’ll trigger the pipeline anyway because
it’s close enough within the frequency of the orchestrator. If instead
our orchestrator ran every 15 minutes, it’d still only execute the
pipeline once in the hour. But if we underprovisioned the orchestrator
and ran it only every day, then the pipeline would only execute once a
day. So an important guideline is that the orchestrator needs to run at
least as frequency as your highest frequency pipeline.

In `maestro` an orchestrator is an R script or Quarto like this:

``` r
library(maestro)

schedule <- build_schedule()

run_schedule(
  schedule,
  orch_frequency = "1 hour"
)
```

By passing the `orch_frequency = "1 hour"` to
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md),
we’re saying that we intend to run the orchestrator every 1 hour.

## Comparison with other packages

### {R} targets

[targets](https://docs.ropensci.org/targets/index.html) is a “pipeline
tool for statistics and data science in R”. If you have multiple
connected components of a pipeline, `targets` skips computation of tasks
that are up-to-date. `targets` seems to be primarily used for projects
with a single output (e.g., model, document) where there are multiple
steps that cumulatively take a long time to complete. In contrast,
`maestro` is focused on projects with multiple *independent* pipelines.
Moreover, `maestro` pipelines are primarily used when the
*up-to-dateness* of the source data is unknown (e.g., coming from an API
or database), unlike in `targets` where it determines the
*up-to-dateness* based on the contents of a file.

### {Python} dagster

[Dagster](https://dagster.io/) is an “open source orchestration platform
for the development, production, and observation of data assets”. Like
`maestro`, dagster uses decorators (special comments) to configure *data
assets* (functions). Unlike `maestro`, dagster is primarily for chaining
together dependent components of a multi-step pipeline - a DAG. It also
supports a developer UI and is more fully developed than `maestro` at
the current time.

DAGs are supported in `maestro` by defining `maestroInputs` and
`maestroOutputs` tags, but `maestro` is still predominately geared
toward projects with multiple pipelines running simultaneously or on
different schedules.

## When to not use maestro?

While `maestro` can be used for almost any data engineering task that
can be performed in R, there are cases where it is less appropriate to
use it.

### Streaming and Event-driven

`maestro` does not support streaming (i.e., continuous) or event-driven
pipelines. Only batch processes can be run in `maestro`.

### Hundreds of pipelines

Although there is no hard limit to the number of pipelines you can run
in `maestro` (and there are ways of maximizing its efficiency as the
number of pipelines increases, such as using multiple cores), we advise
against using `maestro` to run *this* many pipelines - at least not in a
single project. There are several reasons for this: (1) the orchestrator
execution time will be become a problem even with multiple cores; (2)
organizing and keeping track of this many pipelines in a single R
project becomes difficult; (3) the number of dependencies to manage in
the project will likely balloon.

If you wish to continue using `maestro` in this scenario, then our
recommendation is to split the jobs into multiple projects all running
on `maestro`.

Nevertheless, if you have hundreds of jobs to run it’s likely an
indicator that your enterprise has matured out of `maestro` into
something a bit more sophisticated.

### High frequency jobs

If you have pipelines that need to run every minute or less you may want
to look for a solution that supports near real time or real time data
processing. The orchestrator may have trouble keeping up if it’s
scheduled to run this often.

### Multiple languages (R + Python)

`maestro` is for R pipelines only. Using `reticulate` may help with
Python in a pinch though.
