test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

testthat::test_that("standardize_country cleans and maps common forms", {
  x <- c("['China: Guangdong']", "Viet Nam", "None")
  res <- ncbimeta::standardize_country(x)

  testthat::expect_equal(res$country_clean[1], "China")
  testthat::expect_false(is.na(res$country_std[1]))

  # Viet Nam often needs aliasing; at minimum it should be cleaned
  testthat::expect_equal(res$country_clean[2], "Viet Nam")

  testthat::expect_true(is.na(res$country_clean[3]))
})
