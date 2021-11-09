polar_init <- function(data, mapping = NULL, ...) {
    data$y <- 1L

    ggplot(data, aes_string("x", "y")) +
        geom_point(mapping = mapping, ...) +
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

polar_connect <- function(data, x1, x2, ...) {
    aes_args = list(
        x = x1,
        y = 1,
        xend = x2,
        yend = 1
    )
    alist = list(...)

    my_aes = do.call("aes_string", aes_args)

    geom_segment_straight(
        my_aes,
        data = data
    )
}