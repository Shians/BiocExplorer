#' @import htmlwidgets
#' @export
bioc_explore <- function(width = NULL, height = NULL) {

    # read the gexf file
    data <- get_bioc_data()

    # create a list that contains the settings
    settings <- list(
    )

    # pass the data and settings using 'x'
    x <- list(
        data = data,
        settings = settings
    )

    # create the widget
    htmlwidgets::createWidget("bioc_explore", x, width = width, height = height)
}
