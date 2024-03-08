roxy_tag_parse.roxy_tag_batonFrequency <- function(x) {
  if(x$raw == "") {
    x$val <- "daily"
  }
  else if(x$raw %in% c("minutely", "hourly", "daily", "weekly", "monthly", "quarterly", "yearly")) {
    x$val <- x$raw
  }
  else {
    roxygen2::roxy_tag_warning(
      x,
      glue::glue(
        "Invalid batonFrequency `{x$raw}`.
        Must be one of 'minutely', 'hourly', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly'"
      )
    )
    return()
  }
  x
}

batonFrequency_roclet <- function() {
  roxygen2::roclet("batonFrequency")
}

roclet_process.roclet_batonFrequency <- function(x, blocks, env, base_path) {
  tags <- roxygen2::block_get_tag(blocks[[1]], "batonFrequency")
  list(
    val = tags$val,
    node = blocks[[1]]$object$topic
  )
}

roclet_output.roclet_batonFrequency <- function(x, results, base_path, ...) {
  cli::cli(glue::glue("{results$node}: {results$val}"))
  invisible(NULL)
}
