#' Clean bracket wrappers across all character/factor columns
#'
#' Applies `clean_field()` to all character/factor columns in a data frame.
#'
#' @param df A data.frame/tibble.
#' @param cols Tidyselect columns to clean (default: all character/factor columns).
#' @return A tibble with cleaned columns.
#' @export
clean_metadata_brackets <- function(df, cols = dplyr::where(~ is.character(.x) || is.factor(.x))) {
  dplyr::as_tibble(df) |>
    dplyr::mutate(dplyr::across({{ cols }}, clean_field))
}
