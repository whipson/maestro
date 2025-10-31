# maestro 0.7.0

### New features

- Conditional pipelines: A new `maestroRunIf` tag that takes an R expression returning a boolean and conditionally runs a pipeline. These can use inputs from upstream DAG pipelines, values from the orchestrator via `run_schedule(..., resources = list())`, or any arbitrary TRUE/FALSE expression.

### Minor changes

- `maestro::invoke()` gains argument `log_to_console` allowing it to print messages, warnings, and errors to the console.

- `last_run_errors()` and friends now return named lists where the name corresponds to the pipe name.

# maestro 0.6.3

### Bug fixes

- Fixed issue with scheduler on certain frequencies over 1 month when the start time was less than 1 year ago.

# maestro 0.6.2

### Minor changes

- Console output of `run_schedule()` simplified. Counts of skipped pipelines removed to avoid confusion with `@maestroSkip` tag. 'Total' now refers to the total number of pipelines invoked in a run - not all pipelines in the project.

### Bug fixes

- `maestro::invoke()` only runs the selected pipeline or DAG rather than accidentally running all pipelines in the schedule (#161)

# maestro 0.6.1

### Minor changes

- `maestro::invoke()` on a DAG pipeline successfully executes the full DAG (#156).

### Bug fixes

- `maestro::invoke()` now properly passes resources (arguments) to pipelines (#157).

- Number of errors reported in `get_status()` is now accurately reported.

# maestro 0.6.0

### New features

- New `maestroFlags` tag that allows passing arbitrary pipeline tags, which is useful for documentation and labeling. Tags are now accessible via `get_flags()`.

- New function `get_slot_usage` to help identify the number of pipelines running on a scheduled time slot.

- New `maestroPriority` tag that determines the order in which pipelines on the same schedule instance execute. Uses integer values from 1-N where 1 is the highest priority.

- `maestroStartTime` now accepts a timestamp formatted like HH:MM:SS. This is useful for pipelines running on a daily or hourly frequency because the date is often arbitrary in those cases (#143). 

### Removed features

- Arguments `logging` and `log_file` in `run_schedule()`, which were deprecated in maestro 0.5.0 are now fully removed.

### Minor changes

- Reduced the cached length of schedule sequences to 2 years in advance. (This only affects workflows where a schedule is cached instead of rebuilt each orchestration run).

### Bug fixes

- `n_pipelines` attribute of `<MaestroPipelineList>` now corresponds correctly to the number of pipelines.

- `create_pipeline` no longer adds extra line breaks where optional tags would be.

# maestro 0.5.3

### Bug fixes

- Fallback within `build_schedule()` to address CRAN check.

# maestro 0.5.2

### Minor changes

- Pipeline schedule sequences are now stored internally inside of `<MaestroPipeline>` objects instead of generated during `run_schedule()`. This has implications when caching a schedule as the sequence only goes out 3 years in advance.

- Performance improvements to `run_schedule()`.

### Bug fixes

- Specifying `maestroHours`, `maestroDays`, `maestroMonths` now correctly adopts the time zone specified in `maestroTz` (#141).

- When using non UTC time zones, the presence of Daylight Savings Time in the `maestroStartTime` is used to adjust the sequence so that invocations occur on the same time interval.

- Other time zone fixes to deal with differing `maestroTz` and system time checks.

- `maestroHours`, was only valid when `maestroFrequency` was specified as 'hourly', but now '1 hour' is also acceptable (same applies for other specifier tags).

# maestro 0.5.1

### Bug fixes

- Updated error messages and documentation to reflect that a `maestroFrequency` of multiple weeks (e.g., 2 weeks) is invalid.

# maestro 0.5.0

### New features

- Pipeline errors, warnings, and messages can now be printed to the console using `run_schedule(log_to_console = TRUE)`. These logs will be interwoven between messages created by `maestro` (#130).

- `run_schedule()` gains `log_to_file` argument to specify whether to log to a file (replaces `logging` and `log_file` arguments).

### Deprecated functionality

- `run_schedule()` arguments `logging` and `log_file` are deprecated. Use `log_to_file = TRUE` to log to a generic maestro.log file or `log_to_file = '[path-to-your-log-file]'` to log to a specific text file.

### Minor changes

- `run_schedule()` now warns if the unit of `orch_frequency` is lower frequency than the highest frequency pipeline in the project.

- `run_schedule()` enforces a minimum `orch_frequency` of 1 year (e.g., '2 years' or more no longer valid).

### Bug fixes

- Message and warning counts are now properly displayed in the status and output of `run_schedule()`, as well as in `last_run_messages()` and `last_run_warnings()`, even if they are below the `maestroLogLevel`.

- Fixed display of `run_schedule()` to have more accurate next run times for pipelines. This issue was evident when running orchestrator on a frequency of daily or lower.

# maestro 0.4.1

### Bug fixes

- Fixed issue where pipelines with a dependency would run on a time schedule even if the upstream pipeline didn't run (and vice versa).

- Fixed output of next scheduled pipelines to better reflect DAG structures.

# maestro 0.4.0

### New features

- Directed acyclic graph (DAG) pipelines - where the output of one pipeline can feed into another - are now available using the `maestroOutputs` and `maestroInputs` tags. Pipelines that input into a downstream pipeline should use the `maestroOutputs` tag. Pipelines that receive input from an upstream pipeline should use the `maestroInputs` tag (#98).

- New function `show_network` for visualizing the connections between pipelines that are connected in a DAG.

- `MaestroSchedule` gains new methods `get_network()` (returns a data.frame) and `show_network()` (returns a visualization using {DiagrammeR}).

- Added catch-all `maestro` tag to identify a function as a pipeline without specifying other configurations.

### Minor changes

- skip argument added to `create_pipeline` to allow for interactive creation of pipelines that default to skip.

### Bug fixes

- Fixed issue with `suggest_orch_frequency` when using different styles of frequency (e.g., 1 day vs. daily) in a single schedule.

- Fixed issue where pipeline sourcing failures were appearing as successful runs in status outputs.

# maestro 0.3.0

This version refactors much of the code base to rely on R6 classes for pipelines and schedules. Pay careful attention to the breaking changes to see how existing code may be impacted.

### Breaking changes

- Schedules are now represented as an R6 object of class `<MaestroSchedule>`. `build_schedule()` returns a MaestroSchedule object that can be passed to `run_schedule()` as normal. To access the schedule table run `get_schedule()`.

- `run_schedule()` no longer returns a list of `$status` and `$artifacts` but now returns/modifies the MaestroSchedule object. Status can be accessed using `get_status(schedule)` and artifacts via `get_artifacts(schedule)`

- `suggest_orch_frequency()` now takes a `<MaestroSchedule>` object.

- Data `example_schedule` removed from the package.

- Skipped pipelines are no longer shown in the CLI output of `run_schedule()`.

- It is now required that all pipeline names are unique. The names of each maestro pipeline function must be unique across the project to support the implementation of DAGs. `build_schedule()` will abort if any non-unique names are detected.

### New features

- Added functions `get_schedule()`, `get_status()`, and `get_artifacts()` for interacting with `<MaestroSchedule>` objects.

- Added function `invoke()` to instantly run a pipeline in a schedule.

### Bug Fixes

- Error messaging is clearer when running functions that wrap around purrr iterators (#115).

# maestro 0.2.0

### New features

- New tags `maestroHours`, `maestroDays`, and `maestroMonths` allows running of pipelines on specific hours of day, days of week, days of month, or months of year (#100).

- `maestroFrequency` tag now accepts the values hourly, daily, weekly, biweekly, monthly, quarterly, and yearly. Argument `orch_frequency` to `run_schedule()` also accepts these values.

### Minor changes

- Changed from `example_schedule` data the pipeline with a schedule of 1 minute to 30 minutes in keeping with best practices for minimum pipeline frequency.

- `suggest_orch_frequency` now uses the smallest interval between any two pipelines (#99).

### Bug Fixes

- Error messages on unintentional overwrites from `create_*()` functions correctly reference name of path or directory that was to be overwritten.

- Fixed cli output of `run_schedule()` to not show skipped pipelines in the next run portion.

# maestro 0.1.2

### Bug Fixes

- Fixed cli output to correctly handle counting of successful runs when pipelines are skipped.

- Performance improvements to `build_schedule()` (#101).

# maestro 0.1.1

### Breaking changes

- Creater functions `create_pipeline()` and `create_maestro` no longer have default arguments for the path to where the scripts are created. Users must explicitly define these paths.

- Argument `log_file` in `run_schedule()` no longer defaults to `./maestro.log` but instead defaults to `NULL`.

### Minor changes

- Creater functions `create_*` now take a boolean `overwrite` argument to make the overwriting of existing pipelines, projects, and orchestrators more explicit.

# maestro 0.1.0

- Initial CRAN submission

# maestro 0.0.4

### Bug fixes

- Fixed the output of the next run for pipelines (#90)

# maestro 0.0.3

### Breaking changes

- `run_schedule()` now returns a list with status and artifacts instead of just a data.frame of the status. Artifacts are any values returned from pipelines. Pipelines that return nothing will have no artifacts.

### Major changes

- New helper function `suggest_orch_frequency()` to provide a suggestion of what frequency to use for the orchestrator.

### Minor changes

- Start and end times are now reported from functions that result in an error in single core only (#82).

### Bug fixes

- CLI output from `run_schedule()` now correctly outputs the total number of pipelines (#81) and correctly outputs number of errors.

# maestro 0.0.2

### Breaking changes

- maestroFrequency tag now adheres to a more human-readable format like "1 day", "2 hours", "4 weeks", etc.

- `orch_frequency` argument in `run_schedule()` also takes more human-readable format identical to maestroFrequency tag.

- maestroInterval tag removed

- `orch_interval` argument to `run_schedule()` removed.

- `create_maestro()` and `create_orchestrator()` now use the argument `type` instead of `extension` for defining what script type to use for the orchestrator.

- Changed `last_parsing_errors()` to `last_build_errors()`; changed functions of the form `last_runtime_*()` to `last_run_*()`.

### Major changes

- Additional columns added to the output of `run_schedule()`: `pipeline_started` and `pipeline_ended` to indicate the start and end times of a pipeline execution; `next_run` to indicate when the next run should be based on the frequency of the pipeline and orchestrator.

- Pipelines now show as skipped if they are not scheduled.

- Added hex logo

### Minor changes

- Backend improvements to schedule checking

- Timestamps are formatted to specified time zone.

- `run_schedule()` cli output suggests to use `last_run_errors()` or `last_run_warnings()` if any errors or warnings were found.
