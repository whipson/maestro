This orchestrator is run in a scheduled environment.

## What the package will do

-   Create the .qmd or .R orchestrator
    -   Look for pipeline files and add them to the resources header
-   Templates for the pipelines
-   Focus is on a single R project
-   Functions for testing orchestrator and individual pipelines

## Orchestrator

### What orchestrator has to do:

-   Find all .R jobs in specified `pipelines` folder
-   Parse the roxygen tags to build a schedule table/metadata table that "lives" in the project (temporary)
-   Use the schedule table to find which jobs to run during current run of the orchestrator
-   (Optionally) use `future` for multicore processing
-   Run the jobs
-   Failure handling if one pipeline fails (automatically do all jobs in a `tryCatch`)
-   Logging
    -   Success/fail of the individual pipelines - indicate which node (part of the pipeline) failed
    -   Metadata around start time/end time
    -   Optional putting logs into data.frame instead of just text file

### What orchestrator *could* do:

-   Output `gt` of job status, runtime, \# rows input/output

    -   Really cool: Accordian-style based on subpipes within pipes
    -   Network graph of the pipeline to show where in the pipeline things are

-   Performance profiling of the orchestrator/pipelines

    -   More for use in interactive cases where users want to see things like which pipes took the longest, which nodes were causing bottlenecks etc.

### What orchestrator will not do:

-   Source all the functions in /R. User will source those as needed.
-   Not proscriptive about R style
-   Logging of the pipelines themselves is on the user (except warnings and errors)
-   Deployment
-   Notifications/monitoring
-   No enforcement or suggestions around optimal scheduling frequency of the orchestrator
-   No using custom schedule table
-   Use of `library`, `require` is fine - but suggested in the pipelines instead of orchestrator
