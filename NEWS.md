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
