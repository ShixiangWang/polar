#' Init a dot plot in polar system
#'
#' @param data a `data.frame` contains all events, e.g., genes.
#' @param x the column name (without quote) storing event list.
#' @param ... parameters passing to [ggplot2::geom_point].
#'
#' @importFrom ggplot2 .pt aes_string alpha coord_polar element_blank
#' expand_limits geom_point geom_segment ggplot ggproto labs theme
#' zeroGrob
#'
#' @return a `ggplot` object.
#' @export
#'
#' @examples
#' # -------------------
#' #  Init a polar plot
#' # -------------------
#'
#' data <- data.frame(x = LETTERS[1:7])
#'
#' p1 <- polar_init(data, x = x)
#' p1
#'
#' # Set aes value
#' p2 <- polar_init(data, x = x, size = 3, color = "red", alpha = 0.5)
#' p2
#'
#' # Set aes mapping
#' set.seed(123L)
#' data1 <- data.frame(
#'   x = LETTERS[1:7],
#'   shape = c("r", "r", "r", "b", "b", "b", "b"),
#'   color = c("r", "r", "r", "b", "b", "b", "b"),
#'   size = abs(rnorm(7))
#' )
#' # Check https://ggplot2.tidyverse.org/reference/geom_point.html
#' # for how to use both stroke and color
#' p3 <- polar_init(data1, x = x, aes(size = size, color = color, shape = shape), alpha = 0.5)
#' p3
#'
#' # --------------------
#' #  Connect polar dots
#' # --------------------
#' data2 <- data.frame(
#'   x1 = LETTERS[1:7],
#'   x2 = c("B", "C", "D", "E", "C", "A", "C"),
#'   color = c("r", "r", "r", "b", "b", "b", "b")
#' )
#' p4 <- p3 + polar_connect(data2, x1, x2)
#' p4
#'
#' # Unlike polar_init, mappings don't need to be included in aes()
#' p5 <- p3 + polar_connect(data2, x1, x2, color = color, alpha = 0.8, linetype = 2)
#' p5
#'
#' # Use two different color scales
#' if (requireNamespace("ggnewscale")) {
#'   library(ggnewscale)
#'   p6 = p3 +
#'     new_scale("color") +
#'     polar_connect(data2, x1, x2, color = color, alpha = 0.8, linetype = 2)
#'   p6 + scale_color_brewer()
#'   p6 + scale_color_manual(values = c("darkgreen", "magenta"))
#' }
polar_init <- function(data, x, ...) {
  stopifnot(is.data.frame(data))
  data$y <- 1L
  calls <- lapply(as.list(match.call()), function(x) {
    if (is.symbol(x)) as.character(x) else x
  })
  stopifnot(!is.null(calls$x))

  ggplot(data, aes_string(calls$x, "y")) +
    geom_point(...) +
    coord_polar() +
    expand_limits(y = c(0, 1)) +
    theme(
      axis.text.y = element_blank(),
      axis.line.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_blank()
    ) +
    labs(y = NULL, x = NULL)
}


#' Connects dots
#'
#' Check [polar_init()] for examples.
#'
#' @param data a `data.frame` contains connections of all events.
#' @param x1,x2 the column names (without quote) storing connected events.
#' @param ... parameters passing to [ggplot2::geom_segment],
#' expect `c(x, xend, y, yend)` these 4 mapping parameters.
#'
#' @return a `ggplot` object.
#' @export
polar_connect <- function(data, x1, x2, ...) {
  stopifnot(is.data.frame(data))
  calls <- lapply(as.list(match.call()), function(x) {
    if (is.symbol(x)) as.character(x) else x
  })
  stopifnot(!is.null(calls$x1), !is.null(calls$x2))

  aes_args <- list(
    x = calls$x1,
    y = 1,
    xend = calls$x2,
    yend = 1
  )

  alist <- calls[setdiff(names(calls), c("x1", "x2", "", "data"))]
  if (length(alist) > 0) {
    dot_list <- alist

    aes_appends <- sapply(alist, function(x) {
      x %in% colnames(data)
    })
    if (sum(aes_appends) > 0) {
      aes_args <- c(aes_args, alist[aes_appends])
      dot_list <- alist[!aes_appends]
    }
  } else {
    dot_list <- list(...)
  }

  my_aes <- do.call("aes_string", aes_args)

  do.call("geom_segment_straight",
    args = c(
      list(
        mapping = my_aes,
        data = data
      ),
      dot_list
    )
  )
}
