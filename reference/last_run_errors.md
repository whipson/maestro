# Retrieve latest maestro pipeline errors

Gets the latest pipeline errors following use of
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).
If the all runs succeeded or
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
has not been run it will be `NULL`.

## Usage

``` r
last_run_errors()
```

## Value

error messages

## Examples

``` r
last_run_errors()
#> NULL
```
