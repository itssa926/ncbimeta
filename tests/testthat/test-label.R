testthat::test_that("build_tree_label compacts unknown date components", {
  df <- data.frame(
    accession = "ABC123",
    host = "human",
    date_std = "2020-??-??",
    country_tailored = "China",
    stringsAsFactors = FALSE
  )
  out <- ncbimeta::build_tree_label(df, cols = tidyselect::all_of(c("accession","host","date_std","country_tailored")))
  testthat::expect_equal(out$label[1], "ABC123|human|2020|China")
})
