#' Get data from bioconductor
#'
#' @return json string containing bioconductor package details
#' @export
#'
#' @examples
#' bioc_data <- get_bioc_data
get_bioc_data <- function() {
    full_data <- process_data(
        pkg_list = BiocPkgTools::getBiocPkgList(),
        raw_dl_stats = BiocPkgTools::getBiocDownloadStats()
    )

    full_data$tags <- as.character(full_data$tags) %>%
        stringr::str_replace_all("[[:blank:]]", "") %>%
        stringr::str_replace_all("\n", "")

    full_data <- full_data %>%
        dplyr::filter(!is.na(tags))

    jsonlite::toJSON(full_data)
}

# process retrieved data into required data.frame columns
process_data <- function(pkg_list, raw_dl_stats) {
    dl_stats <- summarise_dl_stats(raw_dl_stats)

    pkg_link <- function(pkg) {
        stringr::str_interp(
            "http://bioconductor.org/packages/release/bioc/html/${pkg}.html"
        )
    }

    # convert from factor to character to avoid inner_join warning
    pkg_list$Package <- as.character(pkg_list$Package)
    dl_stats$Package <- as.character(dl_stats$Package)

    full_data <- dplyr::inner_join(pkg_list, dl_stats, by = "Package") %>%
        dplyr::select(
            Author,
            Package,
            License,
            biocViews,
            Description,
            downloads_month,
            downloads_total
        ) %>%
        dplyr::mutate(
            page = pkg_link(Package),
            package = stringr::str_split(biocViews, ", ")
        ) %>%
        dplyr::rename(
            authors = Author,
            name = Package,
            license = License,
            tags = biocViews,
            description = Description
        )

    full_data$authors <- author_list_to_string(full_data$authors)

    full_data
}

# summarise download stats into monthly and total lifetime downloads
summarise_dl_stats <- function(dl_stats) {
    dl_stats %>%
        dplyr::group_by(Package) %>%
        dplyr::summarise(
            downloads_month = dplyr::first(Nb_of_downloads),
            downloads_total = sum(Nb_of_downloads)
        )
}

# collapse list of names into a comma separated string
# final two authors separated by 'and'
author_list_to_string <- function(authors) {
    collapse_list <- function(x) unlist(x) %>% paste(collapse = ", ")
    sapply(authors, collapse_list) %>%
        stringr::str_replace(" and ", ", ") %>%
        stringr::str_replace(",([^,]*)$", " and\\1")
}
