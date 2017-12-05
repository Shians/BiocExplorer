#' @import htmlwidgets
#' @export
bioc_explore <- function(width = NULL, height = NULL, elementId = NULL) {

    # read the gexf file
    # data <- get_bioc_data()
    data <- list(
        message = "Hello, world!"
    )

    # create a list that contains the settings
    settings <- list(
    )

    # pass the data and settings using 'x'
    x <- list(
        data = data,
        settings = settings
    )

    # create the widget
    # create widget
    htmlwidgets::createWidget(
        name = 'bioc_explore',
        x,
        width = width,
        height = height,
        package = 'BioCExplorer',
        elementId = elementId
    )
}
