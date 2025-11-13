# Create a new orchestrator

Create a new orchestrator

## Usage

``` r
create_orchestrator(
  path,
  type = c("R", "Quarto", "RMarkdown"),
  open = interactive(),
  quiet = FALSE,
  overwrite = FALSE
)
```

## Arguments

- path:

  file path for the orchestrator script

- type:

  file type for the orchestrator (supports R, Quarto, and RMarkdown)

- open:

  whether or not to open the script upon creation

- quiet:

  whether to silence messages in the console (default = `FALSE`)

- overwrite:

  whether to overwrite an existing orchestrator or maestro project

## Value

invisible
