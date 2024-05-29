# Package environment for storing state
# Currently used in error reporting scenarios like `last_build_errors`
maestro_pkgenv <- new.env(parent = emptyenv())
