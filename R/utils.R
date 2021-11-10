`%:::%` <- function(pkg, fun, inherits = TRUE) {
  get(fun,
      envir = asNamespace(pkg),
      inherits = inherits
  )
}


remove_missing <- "ggplot2"%:::%"remove_missing"
empty <- "ggplot2"%:::%"empty"
