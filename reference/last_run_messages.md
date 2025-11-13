# Retrieve latest maestro pipeline messages

Gets the latest pipeline messages following use of
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md).
If there are no messages or
[`run_schedule()`](https://whipson.github.io/maestro/reference/run_schedule.md)
has not been run it will be `NULL`.

## Usage

``` r
last_run_messages()
```

## Value

messages

## Details

Note that setting `maestroLogLevel` to something greater than `INFO`
will ignore messages.

## Examples

``` r
last_run_messages()
#> NULL
```
