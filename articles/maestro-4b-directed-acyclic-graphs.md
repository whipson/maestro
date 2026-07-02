# Advanced DAGs - Dynamic Fan-out and Collect

More complex types of DAGs involve dynamically spawning new pipelines
(dynamic fan-out) based on a list or vector and/or collecting inputs
from multiple pipelines into a single pipeline.

## Dynamic Fan-out

Sometimes an upstream pipeline returns a collection of values and you
want to run a downstream pipeline **once per element** — a pattern
called fan-out or scatter. Add `@maestroMap` to the downstream pipeline
to enable this. An empty `@maestroMap` tag iterates over each element of
the upstream return value directly.

    get_letters
      |-shout[1]
      |-shout[2]
      |-shout[3]

``` r

#' @maestroFrequency daily
get_letters <- function() {
  c("a", "b", "c")
}

#' @maestroInputs get_letters
#' @maestroMap
shout <- function(.input) {
  toupper(.input)
}
```

`shout` will execute three times — once for `"a"`, once for `"b"`, once
for `"c"` — and the CLI output labels each branch with its iteration
index in square brackets.

``` r

library(maestro)

schedule <- build_schedule(quiet = TRUE)

run_schedule(schedule, run_all = TRUE)

get_artifacts(schedule)
```


                                                                                    
    ── [2026-07-02 12:51:09]                                                        
    Running pipelines ▶                                                             
    ✔ get_letters [24ms]                                                            
    ✔ |-shout[1] [28ms]                                                             
    ✔ |-shout[2] [23ms]                                                             
    ✔ |-shout[3] [12ms]                                                             
                                                                                    
    ── [2026-07-02 12:51:09]                                                        
    Pipeline execution completed ■ | 0.239 sec elapsed                              
    ✔ 4 successes | ! 0 warnings | ✖ 0 errors | ◼ 4 total                           
    ────────────────────────────────────────────────────────────────────────────────
                                                                                    
    ── Maestro Schedule with 2 pipelines:                                           
    • Success                                                                       
    $get_letters                                                                    
    [1] "a" "b" "c"                                                                 
                                                                                    
    $shout                                                                          
    $shout$uuP1Tj                                                                   
    [1] "A"                                                                         
                                                                                    
    $shout$yTKKHP                                                                   
    [1] "B"                                                                         
                                                                                    
    $shout$fjPLUt                                                                   
    [1] "C"                                                                         
                                                                                    
                                                                                    

Note there is no `@maestroOutputs` equivalent for defining dynamic
fan-out. Here, you must use `@maestroInputs` combined with
`@maestroMap`.

### Iterating over a field of a list

When the upstream pipeline returns a **named list**, use `@maestroMap`
to select which field to scatter over. The full list remains available
as `.input` inside each branch, so other fields are still accessible.

``` r

#' @maestroFrequency daily
get_letters <- function() {
  list(
    letter = letters[1:3],
    greeting = "hello"
  )
}

#' @maestroInputs get_letters
#' @maestroMap .input$letter
make_message <- function(.input) {
  paste(.input$greeting, toupper(.input$letter))
}
```

`make_message` runs once per element of `letter`, producing `"hello A"`,
`"hello B"`, `"hello C"`. The `greeting` field is available in every
branch because the full list is passed as `.input` each time.

``` r

library(maestro)

schedule <- build_schedule(quiet = TRUE)

run_schedule(schedule, run_all = TRUE)

get_artifacts(schedule)
```


                                                                                    
    ── [2026-07-02 12:51:09]                                                        
    Running pipelines ▶                                                             
    ✔ get_letters [10ms]                                                            
    ✔ |-make_message[1] [10ms]                                                      
    ✔ |-make_message[2] [10ms]                                                      
    ✔ |-make_message[3] [10ms]                                                      
                                                                                    
    ── [2026-07-02 12:51:09]                                                        
    Pipeline execution completed ■ | 0.098 sec elapsed                              
    ✔ 4 successes | ! 0 warnings | ✖ 0 errors | ◼ 4 total                           
    ────────────────────────────────────────────────────────────────────────────────
                                                                                    
    ── Maestro Schedule with 2 pipelines:                                           
    • Success                                                                       
    $get_letters                                                                    
    $get_letters$letter                                                             
    [1] "a" "b" "c"                                                                 
                                                                                    
    $get_letters$greeting                                                           
    [1] "hello"                                                                     
                                                                                    
                                                                                    
    $make_message                                                                   
    $make_message$xFnbSr                                                            
    [1] "hello A"                                                                   
                                                                                    
    $make_message$NfwRfN                                                            
    [1] "hello B"                                                                   
                                                                                    
    $make_message$yVywTt                                                            
    [1] "hello C"                                                                   
                                                                                    
                                                                                    

If the field name in `@maestroMap` does not exist in the upstream return
value, maestro records an informative error on the downstream pipeline
rather than silently producing zero branches.

### Iterating over multiple fields simultaneously

You can supply multiple space-separated expressions to `@maestroMap` to
zip across several fields at once — similar to
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html). Each
iteration receives `.input` with all specified fields replaced by their
i-th element.

``` r

#' @maestroFrequency daily
get_data <- function() {
  list(
    letter = letters[1:3],
    greeting = c("hello", "cheers", "hi")
  )
}

#' @maestroInputs get_data
#' @maestroMap .input$letter .input$greeting
make_message <- function(.input) {
  paste(.input$greeting, toupper(.input$letter))
}
```

This produces `"hello A"`, `"cheers B"`, `"hi C"` — each branch receives
a distinct `(letter, greeting)` pair.

All vectors must be the same length, or length 1 (in which case the
scalar is recycled across all iterations). Mismatched lengths produce a
pipeline error.

## Fan-in (Collect)

Fan-in is the complement of fan-out: multiple upstream pipelines are
gathered into a single downstream pipeline. Wrap one or more upstream
names with `collect()` in `@maestroInputs` to enable this.

    letter_a ─┐
               |-+combine
    letter_b ─┘

The downstream pipeline receives a named list as `.input`, where each
name corresponds to an upstream pipeline and each value is that
pipeline’s return value.

``` r

#' @maestroFrequency daily
letter_a <- function() "a"

#' @maestroFrequency daily
letter_b <- function() "b"

#' @maestroInputs collect(letter_a, letter_b)
combine <- function(.input) {
  paste0(.input$letter_a, .input$letter_b)
}
```

`combine` fires only after both `letter_a` and `letter_b` have
succeeded. Inside `combine`, `.input$letter_a` is `"a"` and
`.input$letter_b` is `"b"`. Collect pipelines are shown with a `|-+`
prefix in the CLI to distinguish them from regular downstream pipelines.

``` r

library(maestro)

schedule <- build_schedule(quiet = TRUE)

run_schedule(schedule, run_all = TRUE)

get_status(schedule)[, c("pipe_name", "invoked", "success", "input_run_id", "lineage")]
```


                                                                                    
    ── [2026-07-02 12:51:10]                                                        
    Running pipelines ▶                                                             
    ✔ letter_a [13ms]                                                               
    ✔ letter_b [10ms]                                                               
    ✔ |-+combine [12ms]                                                             
                                                                                    
    ── [2026-07-02 12:51:10]                                                        
    Pipeline execution completed ■ | 0.086 sec elapsed                              
    ✔ 3 successes | ! 0 warnings | ✖ 0 errors | ◼ 3 total                           
    ────────────────────────────────────────────────────────────────────────────────
                                                                                    
    ── Maestro Schedule with 3 pipelines:                                           
    • Success                                                                       
    # A tibble: 3 × 5                                                               
      pipe_name invoked success input_run_id   lineage                              
      <chr>     <lgl>   <lgl>   <chr>          <chr>                                
    1 letter_a  TRUE    TRUE    NA             letter_a                             
    2 letter_b  TRUE    TRUE    NA             letter_b                             
    3 combine   TRUE    TRUE    BRVGSu, s1XzVQ letter_a&letter_b->combine           

If any upstream pipeline fails, the collect pipeline will not fire. The
failed pipeline’s run ID is also excluded from `input_run_id` in
[`get_status()`](https://whipson.github.io/maestro/reference/get_status.md).

### Fan-out into Fan-in

`@maestroMap` and `collect()` compose naturally. An upstream pipeline
can fan out with `@maestroMap`, and a downstream pipeline can gather all
successful iterations back together with `collect()`. Note that in the
dynamic fan-out to fan-in case, the downstream pipeline will run if at
least one upstream iteration has succeeded.

    numbers
      |-multiply[1] ─┐
      |-multiply[2] ──|-+add
      |-multiply[3] ─┘

``` r

#' @maestroFrequency daily
numbers <- function() 1:3

#' @maestroInputs numbers
#' @maestroMap
multiply <- function(.input) .input * 3

#' @maestroInputs collect(multiply)
add <- function(.input) {
  sum(unlist(.input))
}
```

Here `multiply` executes three times (once per element of `1:3`), then
`add` collects all three results and sums them. The `.input` received by
`add` is a list of the successful iteration return values.

``` r

library(maestro)

schedule <- build_schedule(quiet = TRUE)

run_schedule(schedule, run_all = TRUE)

get_artifacts(schedule)$add
```


                                                                                    
    ── [2026-07-02 12:51:10]                                                        
    Running pipelines ▶                                                             
    ✔ numbers [10ms]                                                                
    ✔ |-multiply[1] [28ms]                                                          
    ✔ |-multiply[2] [10ms]                                                          
    ✔ |-multiply[3] [10ms]                                                          
    ✔   |-+add [10ms]                                                               
                                                                                    
    ── [2026-07-02 12:51:10]                                                        
    Pipeline execution completed ■ | 0.137 sec elapsed                              
    ✔ 5 successes | ! 0 warnings | ✖ 0 errors | ◼ 5 total                           
    ────────────────────────────────────────────────────────────────────────────────
                                                                                    
    ── Maestro Schedule with 3 pipelines:                                           
    • Success                                                                       
    [1] 18                                                                          
