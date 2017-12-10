#' @import htmlwidgets
#' @export
bioc_explore <- function(top = 500, ...) {
    # instruction messages
    message("- Hover over bubbles to see full name and lifetime downloads")
    message("- Click on bubbles to see more information about package")
    message("- Use filter to filter by biocViews")

    data <- list(
        data = get_bioc_data(),
        top = top
    )

    settings <- list(
    )

    x <- list(
        data = data,
        settings = settings
    )

    # create the widget
    # create widget
    htmlwidgets::createWidget(
        name = 'bioc_explore',
        package = 'BioCExplorer',
        x = x,
        ...
    )
}
