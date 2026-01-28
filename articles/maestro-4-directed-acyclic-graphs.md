# Directed Acyclic Graphs (DAGs)

A [directed acyclic
graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph) or DAG is a
kind of network graph where nodes are connected by edges, and these
connections cannot loop back or cycle. Most data orchestration tools lay
out a data pipeline as a DAG where data is passed from one function to
the next until it reaches the end. This allows for more module,
single-purpose functions and can make it easier to identify where errors
are occurring.

You can create DAG pipelines in maestro using the `maestroInputs` and/or
`maestroOutputs` tags. Let’s see this in action.

We’ll create three simple pipelines. `start` outputs a vector,
`high_road` takes an input and makes it all uppercase, `low_road` makes
the input all lowercase. We use the `maestroOutputs` tag to indicate the
names of the downstream pipelines (i.e., these pipelines use the output
of the target pipeline as input) and we use the `maestroInputs` tag to
indicate the names of pipelines that are used as input.[¹](#fn1)

Note the use of `.input` as a parameter for all pipelines that receive
an input. It is important to have this here to enable the passing of
data from inputs to outputs. It must be named `.input`.

``` r
#' ./pipelines/dags.R
#' @maestroOutputs high_road low_road
start <- function() {
  c('a', 'A')
}

#' @maestroInputs start
high_road <- function(.input) {
  toupper(.input)
}

#' @maestroInputs start
low_road <- function(.input) {
  tolower(.input)
}
```

Now we’ll create and run the schedule. Notice that the output in the
console will reflect the network structure of the DAG.

``` r
# ./orchestrator.R
library(maestro)

schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule,
  run_all = TRUE
)

get_artifacts(schedule)
```

                                                                                    
    ── [2026-01-28 13:20:04]                                                        
    Running pipelines ▶                                                             
    ✔ start [21ms]                                                                  
    ✔ high_road [26ms]                                                              
    ✔ low_road [9ms]                                                                
                                                                                    
    ── [2026-01-28 13:20:04]                                                        
    Pipeline execution completed ■ | 0.116 sec elapsed                              
    ✔ 3 successes | ! 0 warnings | ✖ 0 errors | ◼ 3 total                           
    ────────────────────────────────────────────────────────────────────────────────
    $start                                                                          
    [1] "a" "A"                                                                     
                                                                                    
    $high_road                                                                      
    [1] "A" "A"                                                                     
                                                                                    
    $low_road                                                                       
    [1] "a" "a"                                                                     
                                                                                    

## ETL Example

A great case for using DAGs is with ETL/ELT pipelines. Each component of
extract, transform, and load could be a single element in the DAG.
Consider the example on the home page:

``` r
#' Example ETL pipeline
#' @maestroFrequency 1 day
#' @maestroStartTime 2024-03-25 12:30:00
my_etl <- function() {
  
  # Pretend we're getting data from a source
  message("Get data")
  extracted <- mtcars
  
  # Transform
  message("Transforming")
  transformed <- extracted |> 
    dplyr::mutate(hp_deviation = hp - mean(hp))
  
  # Load - write to a location
  message("Writing")
  write.csv(transformed, file = paste0("transformed_mtcars_", Sys.Date(), ".csv"))
}
```

It’s pretty concise, so we probably wouldn’t bother breaking it apart in
practice, but let’s do it for illustrative purposes (and also get rid of
the messaging).

``` r
#' @maestroFrequency 1 day
#' @maestroStartTime 2024-03-25 12:30:00
#' @maestroOutputs transform
extract <- function() {
  # Imagine this is something way more complicated, like a database call
  mtcars
}

#' @maestroOutputs load
transform <- function(.input) {
  .input |> 
    dplyr::mutate(hp_deviation = hp - mean(hp))
}

#' @maestro
load <- function(.input) {
  write.csv(.input, file = paste0("transformed_mtcars.csv"))
}
```

``` r
library(maestro)

schedule <- build_schedule(quiet = TRUE)

status <- run_schedule(
  schedule,
  run_all = TRUE
)
```

                                                                                    
    ── [2026-01-28 13:20:04]                                                        
    Running pipelines ▶                                                             
    ✔ extract [9ms]                                                                 
    ✔ transform [13ms]                                                              
    ✔ load [9ms]                                                                    
                                                                                    
    ── [2026-01-28 13:20:04]                                                        
    Pipeline execution completed ■ | 0.063 sec elapsed                              
    ✔ 3 successes | ! 0 warnings | ✖ 0 errors | ◼ 3 total                           
    ────────────────────────────────────────────────────────────────────────────────

When developing these pipelines, it is helpful to visualize the
dependency structure. We can do this by calling
[`show_network()`](https://whipson.github.io/maestro/reference/show_network.md)
on the schedule:

------------------------------------------------------------------------

1.  Specifying the outputs and inputs is redundant. You can specify just
    the outputs or just the inputs if you like, but make sure all
    pipelines are identified as maestro pipelines by including at least
    one maestro tag (you could make use of the catch-all `@maestro` tag
    for this.
