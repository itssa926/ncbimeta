#' Extract country name from NCBI-style location strings
#'
#' Cleans wrappers (e.g. `[`China: Guangdong`]`) and keeps only the country part
#' before ":".
#'
#' @param x A character vector (raw country/location strings).
#' @param strip_wrappers Logical; if TRUE, run `clean_field()` first.
#' @return A character vector of cleaned country names (may include NA).
#' @export
clean_country <- function(x, strip_wrappers = TRUE) {
  x <- as.character(x)
  x <- if (strip_wrappers) clean_field(x) else stringr::str_trim(x)

  # keep only part before ":" (NCBI often uses "Country: region")
  x <- stringr::str_split_fixed(x, ":", 2)[, 1]
  x <- stringr::str_trim(x)

  x[x %in% c("None", "", "NA", "N/A")] <- NA_character_
  x
}

#' Standardize country names and generate ISO codes
#'
#' Uses `countrycode` to standardize country names and produce ISO2/ISO3 codes.
#'
#' @param x A character vector (raw country/location strings).
#' @param origin Passed to `countrycode::countrycode()` (default "country.name").
#' @param destination_name Destination for standardized country names (default "country.name").
#' @param strip_wrappers Logical; if TRUE, run `clean_country()` with wrapper removal.
#' @return A tibble with `country_clean`, `country_std`, `iso2c`, `iso3c`.
#' @export
standardize_country <- function(
    x,
    origin = "country.name",
    destination_name = "country.name",
    strip_wrappers = TRUE
) {
  country_clean <- clean_country(x, strip_wrappers = strip_wrappers)

  country_std <- countrycode::countrycode(
    country_clean,
    origin = origin,
    destination = destination_name,
    warn = FALSE
  )

  iso2c <- countrycode::countrycode(
    country_clean,
    origin = origin,
    destination = "iso2c",
    warn = FALSE
  )

  iso3c <- countrycode::countrycode(
    country_clean,
    origin = origin,
    destination = "iso3c",
    warn = FALSE
  )

  tibble::tibble(
    country_clean = country_clean,
    country_std = country_std,
    iso2c = iso2c,
    iso3c = iso3c
  )
}

#' List unique unmatched country values
#'
#' @param x A character vector (raw country/location strings).
#' @param ... Passed to `standardize_country()`.
#' @return A character vector of unique cleaned countries that failed to map.
#' @export
country_unmatched_values <- function(x, ...) {
  res <- standardize_country(x, ...)
  sort(unique(res$country_clean[!is.na(res$country_clean) & is.na(res$country_std)]))
}
