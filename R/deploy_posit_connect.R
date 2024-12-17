#' Title
#'
#' @param server
#' @param account
#' @param orchestrator
#' @param pipeline_dir
#'
#' @return
#' @export
#'
#' @examples
deploy_posit_connect <- function(
    server = Sys.getenv(paste0(prefix, "_SERVER"), NA_character_),
    api_key = Sys.getenv(paste0(prefix, "_API_KEY"), NA_character_),
    prefix = "CONNECT",
    orchestrator = "orchestrator.qmd",
    pipeline_dir = "pipelines",
    name = "maestro",
    write_manifest_args = list()
  ) {

  rlang::check_installed(c("rsconnect", "connectapi"))

  ext <- tools::file_ext(orchestrator)

  if (!file.exists(orchestrator)) {
    cli::cli_abort(
      "No file called {.file {orchestrator}}."
    )
  }

  if (!dir.exists(pipeline_dir)) {
    cli::cli_abort("No directory called {.emph {pipeline_dir}}")
  }

  if (tolower(ext) != "qmd" && tolower(ext) != "rmd") {
    cli::cli_abort(
      "Orchestrator script must a .qmd or .Rmd file."
    )
  }

  # Attempt to connect to the client
  client <- connectapi::connect(
    server = server,
    api_key = api_key,
    prefix = prefix
  )

  pipeline_files <- list.files(pipeline_dir, full.names = TRUE)

  browser()

  do.call(rsconnect::writeManifest, list(
    appFiles = c(orchestrator, pipeline_files),
    appPrimaryDoc = orchestrator,
    write_manifest_args
  ))

  bundle <- connectapi::bundle_dir()

  content <- client |>
    connectapi::deploy(bundle, name = name) |>
    connectapi::poll_task()
}
