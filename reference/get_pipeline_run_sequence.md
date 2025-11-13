# Generate a sequence of run times for a pipeline

Generate a sequence of run times for a pipeline

## Usage

``` r
get_pipeline_run_sequence(
  pipeline_n,
  pipeline_unit,
  pipeline_datetime,
  check_datetime,
  pipeline_hours = 0:23,
  pipeline_days_of_week = 1:7,
  pipeline_days_of_month = 1:31,
  pipeline_months = 1:12
)
```

## Arguments

- pipeline_n:

  number of units for the pipeline frequency

- pipeline_unit:

  unit for the pipeline frequency

- pipeline_datetime:

  datetime of the first time the pipeline is to run

- check_datetime:

  datetime against which to check the running of pipelines (default is
  current system time in UTC)

- pipeline_hours:

  vector of integers \[0-23\] corresponding to hours of day for the
  pipeline to run

- pipeline_days_of_week:

  vector of integers \[1-7\] corresponding to days of week for the
  pipeline to run (1 = Sunday)

- pipeline_days_of_month:

  vector of integers \[1-31\] corresponding to days of month for the
  pipeline to run

- pipeline_months:

  vector of integers \[1-12\] corresponding to months of year for the
  pipeline to run

## Value

vector of timestamps or dates
