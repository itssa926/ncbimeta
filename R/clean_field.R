#' Clean a single metadata field
#'
#' Removes bracket wrappers like `[`xxx`]` or `[`xxx`]`, trims whitespace, and converts
#' common missing tokens to NA.
#'
#' @param x A vector (usually character/factor).
#' @return A character vector.
#' @export
clean_field <- function(x) {
  x <- as.character(x)

  # capture first quoted item inside [...]
  m <- stringr::str_match(x, "\\[\\s*['\"](.*?)['\"]\\s*(?:,.*)?\\]")
  out <- ifelse(
    !is.na(m[, 2]),
    m[, 2],
    x |>
      stringr::str_remove_all("^\\s*\\[\\s*") |>
      stringr::str_remove_all("\\s*\\]\\s*$") |>
      stringr::str_remove_all("^\\s*['\"]|['\"]\\s*$") |>
      stringr::str_trim()
  )

  out[out %in% c("None", "'None'", "\"None\"", "", "NA", "N/A")] <- NA_character_
  out
}
