#' Make strings safe for tree labels / filenames
#'
#' @param x Character vector.
#' @param na_token Replacement for NA/empty.
#' @param ascii Logical; if TRUE, transliterate to ASCII (remove accents).
#' @param tolower Logical; if TRUE, convert to lower case.
#' @param replacement String used to replace invalid characters (default "_").
#' @param allowed_chars_regex Regex character class for allowed characters
#'   (default keeps A-Z a-z 0-9 plus "._|-").
#' @param collapse_replacement Logical; collapse multiple replacements into one.
#' @param trim_replacement Logical; trim replacement at start/end.
#' @return Character vector.
#' @export
make_tree_safe <- function(
    x,
    na_token = "None",
    ascii = TRUE,
    tolower = FALSE,
    replacement = "_",
    allowed_chars_regex = "A-Za-z0-9._\\|-",
    collapse_replacement = TRUE,
    trim_replacement = TRUE
) {
  y <- as.character(x)

  # missing -> token
  y[is.na(y) | stringr::str_trim(y) == ""] <- na_token
  y <- stringr::str_trim(y)

  # normalize unicode accents
  if (ascii) {
    y <- stringi::stri_trans_general(y, "Latin-ASCII")
  }

  # optionally normalize case
  if (tolower) {
    y <- base::tolower(y)
  }

  # remove characters that break Newick / labels badly (optional but sensible default)
  # you can still allow ":" etc by changing allowed_chars_regex
  # Here we just standardize whitespace/invalids to `replacement`
  y <- stringr::str_replace_all(y, paste0("[^", allowed_chars_regex, "]+"), replacement)

  # collapse repeated replacements
  if (collapse_replacement && nzchar(replacement)) {
    rep_esc <- stringr::str_replace_all(replacement, "([\\^$.|?*+()\\[\\]{}\\\\])", "\\\\\\1")
    y <- stringr::str_replace_all(y, paste0(rep_esc, "{2,}"), replacement)
  }

  # trim replacement at edges
  if (trim_replacement && nzchar(replacement)) {
    rep_esc <- stringr::str_replace_all(replacement, "([\\^$.|?*+()\\[\\]{}\\\\])", "\\\\\\1")
    y <- stringr::str_replace_all(y, paste0("^", rep_esc, "|", rep_esc, "$"), "")
  }

  # if cleaning produced empty, fall back to token
  y[stringr::str_trim(y) == ""] <- na_token
  y
}
