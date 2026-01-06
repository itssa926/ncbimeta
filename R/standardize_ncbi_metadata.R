#' Standardize NCBI metadata for phylogenetics
#'
#' Pipeline:
#' 1) Clean bracket wrappers across metadata (`clean_metadata_brackets()`)
#' 2) Standardize dates (`standardize_date()`) -> adds date_std/date_granularity/date_unmatched
#' 3) Standardize countries (`standardize_country()`) -> adds country_clean/country_std/iso2c/iso3c
#' 4) Create a tree-safe country label (`country_tailored`)
#' 5) Build a tree label column joined by `|` (`build_tree_label()`)
#'
#' @param df A data.frame/tibble with NCBI-derived metadata.
#' @param date_col Name of the date column in `df`.
#' @param country_col Name of the country/location column in `df`.
#' @param label_cols Columns used to build the tree label (tidyselect). If NULL, uses a default set.
#' @param label_col_name Output label column name (default "label").
#' @param label_sep Separator for label (default "|").
#' @param na_token Token used for missing values in label/sanitization (default "None").
#' @param sanitize_label_fields Logical; if TRUE, sanitize each label field via `make_tree_safe()`.
#' @return A tibble with standardized metadata columns added.
#' @export
standardize_ncbi_metadata <- function(
    df,
    date_col = "date",
    country_col = "country",
    label_cols = NULL,
    label_col_name = "label",
    label_sep = "|",
    na_token = "None",
    sanitize_label_fields = TRUE
) {
  df <- dplyr::as_tibble(df)

  # 1) clean wrappers across character/factor columns
  df <- clean_metadata_brackets(df)

  # 2) standardize date (3 cols)
  if (!date_col %in% names(df)) {
    rlang::abort(paste0("date_col '", date_col, "' not found in df. Available: ", paste(names(df), collapse = ", ")))
  }
  dres <- standardize_date(df[[date_col]])
  df <- dplyr::bind_cols(df, dplyr::select(dres, date_std, date_granularity, date_unmatched))

  # 3) standardize country (4 cols)
  if (!country_col %in% names(df)) {
    rlang::abort(paste0("country_col '", country_col, "' not found in df. Available: ", paste(names(df), collapse = ", ")))
  }
  cres <- standardize_country(df[[country_col]])
  df <- dplyr::bind_cols(df, cres)

  # 4) tree-safe country label
  # prefer standardized country, fallback to cleaned
  base_country <- dplyr::coalesce(df$country_std, df$country_clean)
  df$country_tailored <- make_tree_safe(base_country, na_token = na_token)

  # 5) build tree label
  if (is.null(label_cols)) {
    # default: accession if present, else use first column as fallback
    default_cols <- c()
    if ("accession" %in% names(df)) default_cols <- c(default_cols, "accession")
    default_cols <- c(default_cols, "date_std", "country_tailored")
    # keep only those that exist
    default_cols <- default_cols[default_cols %in% names(df)]
    if (length(default_cols) == 0) {
      rlang::abort("No default label columns found. Please provide `label_cols = c(...)`.")
    }
    label_cols <- tidyselect::all_of(default_cols)
  }

  df <- build_tree_label(
    df,
    cols = {{ label_cols }},
    sep = label_sep,
    na_token = na_token,
    sanitize = sanitize_label_fields,
    new_col = label_col_name
  )

  df
}
