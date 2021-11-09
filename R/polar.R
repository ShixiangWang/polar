#' Draw polar plot
#'
#' @param data1 a list of dots in a `data.frame` with following columns:
#' - x
#' - dot_shape
#' - dot_color
#' - dot_size
#'
#' @param data2 a list of connection in a `data.frame` with following columns:
#' - x1
#' - x2
#' - segment_color
#' @param dot_alpha alpha for dot
#' @param seg_size size for segment
#' @param seg_alpha alpha for segment
#'
#' @return a `ggplot`
#' @export
#'
#' @examples
#' data1 <- data.frame(
#'   x = letters[1:7],
#'   dot_shape = c("r", "r", "r", "b", "b", "b", "b"),
#'   dot_color = c("r", "r", "r", "b", "b", "b", "b"),
#'   dot_size = abs(rnorm(7))
#' )
#'
#' data2 <- data.frame(
#'   x1 = letters[1:7],
#'   x2 = c("b", "c", "d", "e", "c", "a", "c"),
#'   seg_color = c("r", "r", "r", "b", "b", "b", "b")
#' )
#'
#' polar(data1, data2)
#'
#' @importFrom ggplot2 .pt aes_string alpha coord_polar element_blank
#' expand_limits geom_point geom_segment ggplot ggproto labs theme
#' zeroGrob
polar <- function(data1, data2, dot_alpha = 1, seg_size = 1, seg_alpha = dot_alpha) {
  data1$y <- 1L

  ggplot(data1, aes_string("x", "y")) +
    geom_point(aes_string(shape = "dot_shape", color = "dot_color", size = "dot_size"),
      alpha = dot_alpha
    ) +
    geom_segment_straight(aes_string(
      x = "x1", y = 1, xend = "x2", yend = 1,
      color = "seg_color"
    ),
    size = seg_size, alpha = seg_alpha,
    data = data2
    ) +
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

# https://stackoverflow.com/questions/66196451/draw-straight-line-between-any-two-point-when-using-coord-polar-in-ggplot2-r
geom_segment_straight <- function(...) {
  layer <- geom_segment(...)
  new_layer <- ggproto(NULL, layer)
  old_geom <- new_layer$geom
  geom <- ggproto(
    NULL, old_geom,
    draw_panel = function(data, panel_params, coord,
                          arrow = NULL, arrow.fill = NULL,
                          lineend = "butt", linejoin = "round",
                          na.rm = FALSE) {
      data <- ggplot2:::remove_missing(
        data,
        na.rm = na.rm, c(
          "x", "y", "xend", "yend",
          "linetype", "size", "shape"
        )
      )
      if (ggplot2:::empty(data)) {
        return(zeroGrob())
      }
      coords <- coord$transform(data, panel_params)
      # xend and yend need to be transformed separately, as coord doesn't understand
      ends <- transform(data, x = xend, y = yend)
      ends <- coord$transform(ends, panel_params)

      arrow.fill <- if (!is.null(arrow.fill)) arrow.fill else coords$colour
      return(grid::segmentsGrob(
        coords$x, coords$y, ends$x, ends$y,
        default.units = "native", gp = grid::gpar(
          col = alpha(coords$colour, coords$alpha),
          fill = alpha(arrow.fill, coords$alpha),
          lwd = coords$size * .pt,
          lty = coords$linetype,
          lineend = lineend,
          linejoin = linejoin
        ),
        arrow = arrow
      ))
    }
  )
  new_layer$geom <- geom
  return(new_layer)
}

utils::globalVariables(
  c("xend", "yend")
)
