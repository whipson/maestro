# Create a new pipeline in a pipelines directory

Allows the creation of new pipelines (R scripts) and fills in the
maestro tags as specified.

## Usage

``` r
create_pipeline(
  pipe_name,
  pipeline_dir = "pipelines",
  frequency = "1 day",
  start_time = Sys.Date(),
  tz = "UTC",
  log_level = "INFO",
  quiet = FALSE,
  open = interactive(),
  overwrite = FALSE,
  skip = FALSE,
  inputs = NULL,
  outputs = NULL,
  priority = NULL
)
```

## Arguments

- pipe_name:

  name of the pipeline and function

- pipeline_dir:

  directory containing the pipeline scripts

- frequency:

  how often the pipeline should run (e.g., 1 day, daily, 3 hours, 4
  months). Fills in maestroFrequency tag

- start_time:

  start time of the pipeline schedule. Fills in maestroStartTime tag

- tz:

  timezone that pipeline will be scheduled in. Fills in maestroTz tag

- log_level:

  log level for the pipeline (e.g., INFO, WARN, ERROR). Fills in
  maestroLogLevel tag

- quiet:

  whether to silence messages in the console (default = `FALSE`)

- open:

  whether or not to open the script upon creation

- overwrite:

  whether or not to overwrite an existing pipeline of the same name and
  location.

- skip:

  whether to skip the pipeline when running in the orchestrator (default
  = `FALSE`)

- inputs:

  vector of names of pipelines that input into this pipeline (default =
  `NULL` for no inputs)

- outputs:

  vector of names of pipelines that receive output from this pipeline
  (default = `NULL` for no outputs)

- priority:

  a single positive integer corresponding to the order in which this
  pipeline will be invoked in the presence of other simultaneously
  invoked pipelines.

## Value

invisible

## Examples

``` r
if (interactive()) {
  pipeline_dir <- tempdir()
  create_pipeline(
    "extract_data",
    pipeline_dir = pipeline_dir,
    frequency = "1 hour",
    open = FALSE,
    quiet = TRUE,
    overwrite = TRUE
  )

  create_pipeline(
    "new_job",
    pipeline_dir = pipeline_dir,
    frequency = "20 minutes",
    start_time = as.POSIXct("2024-06-21 12:20:00"),
    log_level = "ERROR",
    open = FALSE,
    quiet = TRUE,
    overwrite = TRUE
  )
}
```
