
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ncbimeta

<!-- badges: start -->
<!-- badges: end -->

ncbimeta provides tools to clean, standardise, and prepare NCBI /
GenBank metadata for phylogenetic analyses. The package focuses on
producing tree-ready, reproducible metadata from heterogeneous and messy
NCBI records.

## Installation

You can install the development version of ncbimeta like so:

``` r
# install.packages("devtools")
devtools::install_github("itssa926/ncbimeta")
```

## Main Workflow

``` r
library(ncbimeta)

toy_df <- data.frame(
  accession = c("ABC123", "XYZ999"),
  collection_date = c("['2020']", "2020-07-03"),
  location = c("['China: Guangdong']", "Viet Nam"),
  host = c("human", "mosquito"),
  stringsAsFactors = FALSE
)

meta_std <- standardize_ncbi_metadata(
  toy_df,
  date_col    = "collection_date",
  country_col = "location",
  label_cols  = tidyselect::all_of(c("accession", "host", "date_std", "country_tailored")),
  label_col_name = "tip_label"
)
#> Warning: Using `all_of()` outside of a selecting function was deprecated in tidyselect
#> 1.2.0.
#> ℹ See details at
#>   <https://tidyselect.r-lib.org/reference/faq-selection-context.html>
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.

meta_std[, c("accession", "date_std", "country_std", "country_tailored", "tip_label")]
#> # A tibble: 2 × 5
#>   accession date_std   country_std country_tailored tip_label                   
#>   <chr>     <chr>      <chr>       <chr>            <chr>                       
#> 1 ABC123    2020-??-?? China       China            ABC123|human|2020-_-|China  
#> 2 XYZ999    2020-07-03 Vietnam     Vietnam          XYZ999|mosquito|2020-07-03|…
```

``` markdown
This single call will:

1. Clean bracket wrappers across metadata
2. Standardise collection dates
3. Standardise country names and ISO codes
4. Generate tree-safe country labels
5. Build a tree tip label
Default label format:
```

``` r
accession|host|date_std|country_tailored
```

## Example

Cleaning Utilities:

``` r
toy_meta <- data.frame(
  date    = c("['2020-01-02']", "None"),
  country = c("['China: Guangdong']", "Viet Nam"),
  stringsAsFactors = FALSE
)

clean_field("['2020-01-02']")
#> [1] "2020-01-02"
clean_metadata_brackets(toy_meta)
#> # A tibble: 2 × 2
#>   date       country         
#>   <chr>      <chr>           
#> 1 2020-01-02 China: Guangdong
#> 2 <NA>       Viet Nam
```

Removes NCBI-style wrappers such as \[‘xxx’\], trims whitespace, and
converts “None”/“” to NA.

Date Standardisation:

``` r
standardize_date(c("['2020']", "2020-07", "2020-07-03", "None"))
#> # A tibble: 4 × 5
#>   date_raw   date_clean date_std   date_granularity date_unmatched
#>   <chr>      <chr>      <chr>      <chr>            <lgl>         
#> 1 ['2020']   2020       2020-??-?? year             FALSE         
#> 2 2020-07    2020-07    2020-07-?? month            FALSE         
#> 3 2020-07-03 2020-07-03 2020-07-03 day              FALSE         
#> 4 None       <NA>       <NA>       unknown          FALSE
```

Returns standardised dates with explicit granularity (year, month, day,
or unknown).

Country Standardisation:

``` r
standardize_country(c("['China: Guangdong']", "Viet Nam", "None"))
#> # A tibble: 3 × 4
#>   country_clean country_std iso2c iso3c
#>   <chr>         <chr>       <chr> <chr>
#> 1 China         China       CN    CHN  
#> 2 Viet Nam      Vietnam     VN    VNM  
#> 3 <NA>          <NA>        <NA>  <NA>
```

Returns cleaned country names and ISO2/ISO3 codes.

Tree-safe String Sanitisation:

``` r
make_tree_safe("São Tomé and Príncipe")
#> [1] "Sao_Tome_and_Principe"
# "Sao_Tome_and_Principe"
```

Applicable to any character column (country, host, strain, etc.).

Custom Tree Labels:

``` r
build_tree_label(
  meta_std,
  cols = c(accession, date_std, country_tailored),
  new_col = "tip_label"
)
#> # A tibble: 2 × 13
#>   accession collection_date location         host     date_std  date_granularity
#>   <chr>     <chr>           <chr>            <chr>    <chr>     <chr>           
#> 1 ABC123    2020            China: Guangdong human    2020-??-… year            
#> 2 XYZ999    2020-07-03      Viet Nam         mosquito 2020-07-… day             
#> # ℹ 7 more variables: date_unmatched <lgl>, country_clean <chr>,
#> #   country_std <chr>, iso2c <chr>, iso3c <chr>, country_tailored <chr>,
#> #   tip_label <chr>
```

Fully configurable

## Author

Sayuan Wang (for internal use)
