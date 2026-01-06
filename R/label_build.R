#' Build tree labels from metadata columns
#'
#' Creates a single label column by pasting selected metadata columns together
#' with a separator (default: "|"). Optionally sanitizes each field using
#' `make_tree_safe()` to avoid problematic characters in tree tools.
#'
#' @param df A data.frame or tibble containing metadata.
#' @param cols Columns to use in the label (tidyselect). Order matters.
#' @param sep Separator used to join fields (default "|").
#' @param na_token Token used when a field is missing/empty (default "None").
#' @param sanitize Logical; if TRUE, apply `make_tree_safe()` to each field before joining.
#' @param new_col Name of the output label column (default "label").
#' @param compact_unknown_dates Logical; if TRUE, compress date strings like
#'   `YYYY-??-??` -> `YYYY` and `YYYY-MM-??` -> `YYYY-MM` before sanitization.
#' @param unknown_token Token used for unknown date components (default "??").
#' @return The input data frame with an added label column.
#' @export
build_tree_label <- function(
    df,
    cols,
    sep = "|",
    na_token = "None",
    sanitize = TRUE,
    new_col = "label",
    compact_unknown_dates = TRUE,
    unknown_token = "??"
) {
  df <- dplyr::as_tibble(df)

  # select columns in user-specified order
  sel <- dplyr::select(df, {{ cols }})

  # convert to character and fill missing
  sel_chr <- dplyr::mutate(sel, dplyr::across(dplyr::everything(), as.character))
  sel_chr <- dplyr::mutate(
    sel_chr,
    dplyr::across(dplyr::everything(), ~ {
      z <- stringr::str_trim(.x)
      z[is.na(z) | z == ""] <- na_token
      z
    })
  )

  # compact unknown date components (works for any column that matches the pattern)
  if (compact_unknown_dates) {
    # escape unknown token for regex, e.g. "??" -> "\\?\\?"
    unk <- stringr::str_replace_all(unknown_token, "([\\\\.^$|?*+()\\[\\]{}-])", "\\\\\\1")

    pat_year  <- paste0("^([0-9]{4})-", unk, "-", unk, "$")       # YYYY-??-??
    pat_month <- paste0("^([0-9]{4}-[0-9]{2})-", unk, "$")        # YYYY-MM-??

    sel_chr <- dplyr::mutate(
      sel_chr,
      dplyr::across(
        dplyr::everything(),
        ~ {
          z <- .x
          z <- stringr::str_replace(z, pat_year, "\\1")   # -> YYYY
          z <- stringr::str_replace(z, pat_month, "\\1")  # -> YYYY-MM
          z
        }
      )
    )
  }

  if (sanitize) {
    sel_chr <- dplyr::mutate(
      sel_chr,
      dplyr::across(dplyr::everything(), ~ make_tree_safe(.x, na_token = na_token))
    )
  }

  label <- do.call(paste, c(as.list(sel_chr), sep = sep))
  df[[new_col]] <- label
  df
}
