#' Standardize collection dates for phylogenetic metadata
#'
#' Parses diverse NCBI/GenBank date strings and returns:
#' - `date_std`: standardized date string using "??" for unknown month/day
#' - `date_granularity`: one of year/month/day/unknown
#' - `date_unmatched`: TRUE when input was non-missing but parsing failed
#'
#' @param x A character vector of dates (raw).
#' @param strip_wrappers Logical; if TRUE, run `clean_field()` first to remove wrappers.
#' @param unknown_token Character token for unknown components (default "??").
#' @param orders lubridate parse orders (character vector).
#' @return A tibble with columns `date_raw`, `date_clean`, `date_std`, `date_granularity`, `date_unmatched`.
#' @export
standardize_date <- function(
    x,
    strip_wrappers = TRUE,
    unknown_token = "??",
    orders = c("Y","Y-m","Y-m-d","Y/m","Y/m/d","d-m-Y","d/m/Y","d-b-Y","d-B-Y","b-Y","B-Y")
) {
  date_raw <- as.character(x)

  date_clean <- if (strip_wrappers) clean_field(date_raw) else stringr::str_trim(date_raw)
  x0 <- ifelse(is.na(date_clean), "", trimws(date_clean))

  parsed <- suppressWarnings(
    lubridate::parse_date_time(x0, orders = orders, exact = FALSE, quiet = TRUE)
  )

  gran <- dplyr::case_when(
    x0 == "" | is.na(parsed) ~ "unknown",
    stringr::str_detect(x0, "^[0-9]{4}$") ~ "year",
    stringr::str_detect(x0, "^[0-9]{4}[-/][0-9]{1,2}$") |
      stringr::str_detect(x0, "^[A-Za-z]{3,9}[-/][0-9]{4}$") ~ "month",
    TRUE ~ "day"
  )

  y   <- ifelse(is.na(parsed), NA_character_, format(parsed, "%Y"))
  ym  <- ifelse(is.na(parsed), NA_character_, format(parsed, "%Y-%m"))
  ymd <- ifelse(is.na(parsed), NA_character_, format(parsed, "%Y-%m-%d"))

  date_std <- dplyr::case_when(
    gran == "year"  ~ paste0(y,  "-", unknown_token, "-", unknown_token),
    gran == "month" ~ paste0(ym, "-", unknown_token),
    gran == "day"   ~ ymd,
    TRUE            ~ NA_character_
  )

  date_unmatched <- x0 != "" & is.na(parsed)

  tibble::tibble(
    date_raw = date_raw,
    date_clean = dplyr::na_if(x0, ""),
    date_std = date_std,
    date_granularity = gran,
    date_unmatched = date_unmatched
  )
}
#' Count unmatched date strings
#'
#' Counts date values that could not be parsed during standardisation.
#'
#' @param x A character vector of raw date strings.
#' @param ... Additional arguments passed to `standardize_date()`.
#'
#' @return An integer count of unmatched date values.
#' @export
count_unmatched_dates <- function(x, ...) {
  res <- standardize_date(x, ...)
  dplyr::count(dplyr::filter(res, date_unmatched), date_clean, sort = TRUE)
}
