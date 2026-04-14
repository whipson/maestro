# Minimum days ahead to pre-compute run sequences on initialization This small window is used at parse time; the full window is built lazily when observability functions (get_run_sequence, get_slot_usage) are called.

Minimum days ahead to pre-compute run sequences on initialization This
small window is used at parse time; the full window is built lazily when
observability functions (get_run_sequence, get_slot_usage) are called.

## Usage

``` r
.run_sequence_min_days_out(unit)
```

## Arguments

- unit:

  character frequency unit

## Value

integer
