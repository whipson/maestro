# Retrieve latest maestro build errors

Gets the latest schedule build errors following use of
[`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md).
If the build succeeded or
[`build_schedule()`](https://whipson.github.io/maestro/reference/build_schedule.md)
has not been run it will be `NULL`.

## Usage

``` r
last_build_errors()
```

## Value

error messages

## Examples

``` r
last_build_errors()
#> NULL
```
