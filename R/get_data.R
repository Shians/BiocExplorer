get_bioc_data <- function() {
    pkg_list <- BiocPkgTools::getBiocPkgList()
    raw_dl_stats <- BiocPkgTools::getBiocDownloadStats()

    full_data <- process_data(pkg_list, raw_dl_stats)

    jsonlite::toJSON(full_data)
}

process_data <- function(raw_dl_stats, pkg_list) {
    dl_stats <- summarise_dl_stats(raw_dl_stats)

    pkg_link <- function(pkg) {
        stringr::str_interp(
            "http://bioconductor.org/packages/release/bioc/html/${pkg}.html"
        )
    }

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

summarise_dl_stats <- function(dl_stats) {
    dl_stats %>%
        dplyr::group_by(Package) %>%
        dplyr::summarise(
            downloads_month = dplyr::first(Nb_of_downloads),
            downloads_total = sum(Nb_of_downloads)
        )
}

author_list_to_string <- function(authors) {
    collapse_list <- function(x) unlist(x) %>% paste(collapse = ", ")
    sapply(authors, collapse_list) %>%
        str_replace(" and ", ", ") %>%
        str_replace(",([^,]*)$", " and\\1")
}
