# Find the most recent cycle point before a given time

Given a repeating cycle anchored at `start` and stepping every `amount`
`unit`s, returns the latest cycle point strictly before `current`.

## Usage

``` r
.prev_on_cycle(
  start,
  current = Sys.time(),
  amount = 1L,
  unit = c("second", "minute", "hour", "day", "week", "month", "year")
)
```

## Arguments

- start:

  `Date` or `POSIXct` defining the cycle origin.

- current:

  `Date` or `POSIXct` (coerced to match `start`) used as the reference
  point. Defaults to
  [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

- amount:

  Positive integer; number of `unit`s per cycle step.

- unit:

  Character; one of `"second"`, `"minute"`, `"hour"`, `"day"`, `"week"`,
  `"month"`, `"year"`. Sub-day units are not supported when `start` is a
  `Date`.

## Value

A `Date` or `POSIXct` of the same class and timezone as `start`, or `NA`
if `current <= start`.
