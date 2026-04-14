# Resolve a partial `@maestroStartTime` string to a concrete POSIXct

Accepts four formats:

- `"HH:MM:SS"` — time of day; anchored to today's date.

- `"Mon HH:MM:SS"` — weekday + time; anchored to that weekday of the
  current ISO week.

- `"DD HH:MM:SS"` or `"DD"` — month-day (+ optional time); anchored to
  that day of the current month.

- Full datetime string — passed through to
  [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html).

## Usage

``` r
parse_maestro_start_time(raw, tz, now = lubridate::now(tzone = tz))
```

## Arguments

- raw:

  Character string from the tag value.

- tz:

  Timezone string.

- now:

  `POSIXct` reference point (default `lubridate::now(tz)`).

## Value

A `POSIXct`, or `NA` if `raw` is `NA`/`""`.

## Details

Using a recent `now` as the reference keeps the anchor close to the
present, so `n` in
[`.prev_on_cycle()`](https://whipson.github.io/maestro/reference/dot-prev_on_cycle.md)
stays small.
