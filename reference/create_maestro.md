# Creates a new maestro project

Creates a new maestro project

## Usage

``` r
create_maestro(path, type = "R", overwrite = FALSE, quiet = FALSE, ...)
```

## Arguments

- path:

  file path for the orchestrator script

- type:

  file type for the orchestrator (supports R, Quarto, and RMarkdown)

- overwrite:

  whether to overwrite an existing orchestrator or maestro project

- quiet:

  whether to silence messages in the console (default = `FALSE`)

- ...:

  unused

## Value

invisible

## Examples

``` r
# Creates a new maestro project with an R orchestrator
if (interactive()) {
  new_proj_dir <- tempdir()
  create_maestro(new_proj_dir, type = "R", overwrite = TRUE)

  create_maestro(new_proj_dir, type = "Quarto", overwrite = TRUE)
}
```
