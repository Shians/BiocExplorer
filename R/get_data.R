library(BiocPkgTools)
library(stringr)
library(dplyr)
library(jsonlite)
library(readr)

pkg_list <- BiocPkgTools::getBiocPkgList()
dl_stats <- BiocPkgTools::getBiocDownloadStats()

dl_stats <- dl_stats %>%
    group_by(Package) %>%
    summarise(
        downloads_month = first(Nb_of_downloads),
        downloads_total = sum(Nb_of_downloads)
    )

pkg_link <- function(pkg) {
    str_interp("http://bioconductor.org/packages/release/bioc/html/${pkg}.html")
}

full_data <- inner_join(pkg_list, dl_stats, by = "Package") %>%
    select(
        Author,
        Package,
        License,
        biocViews,
        Description,
        downloads_month,
        downloads_total
    ) %>%
    mutate(
        page = pkg_link(Package),
        package = str_split(biocViews, ", ")
    ) %>%
    rename (
        authors = Author,
        name = Package,
        license = License,
        tags = biocViews,
        description = Description
    )

collapse_list <- function(x) unlist(x) %>% paste(collapse = ", ")

full_data$authors <- sapply(full_data$authors, collapse_list) %>%
    str_replace(" and ", ", ") %>%
    str_replace(",([^,]*)$", " and\\1")

json <- toJSON(full_data)

write_file(paste("var data =", json), "bioC.json")
