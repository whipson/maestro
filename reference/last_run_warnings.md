# Retrieve latest maestro pipeline warnings

Gets the latest pipeline warnings following use of
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).
If there are no warnings or
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
has not been run it will be `NULL`.

## Usage

``` r
last_run_warnings()
```

## Value

warning messages

## Details

Note that setting `maestroLogLevel` to something greater than `WARN`
will ignore warnings.

## Examples

``` r
last_run_warnings()
#> NULL
```
