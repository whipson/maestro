# maestro (development version)

-   Initial alpha release

# maestro 0.0.2

## Breaking changes

-   maestroFrequency tag now adheres to a more human-readable format like "1 day", "2 hours", "4 weeks", etc.

-   `orch_frequency` argument in `run_schedule()` also takes more human-readable format identical to maestroFrequency tag.

-   maestroInterval tag removed

-   `orch_interval` argument to `run_schedule()` removed.

-   `create_maestro()` and `create_orchestrator()` now use the argument `type` instead of `extension` for defining what script type to use for the orchestrator.

-   Changed `last_parsing_errors()` to `last_build_errors()`; changed functions of the form `last_runtime_*()` to `last_run_*()`.

## Major changes

- Additional columns added to the output of `run_schedule()`: `pipeline_started` and `pipeline_ended` to indicate the start and end times of a pipeline execution; `next_run` to indicate when the next run should be based on the frequency of the pipeline and orchestrator.

- Pipelines now show as skipped if they are not scheduled.

## Minor changes

- Backend improvements to schedule checking

- Timestamps are formatted to specified time zone.
