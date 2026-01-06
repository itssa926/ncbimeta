test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

testthat::test_that("make_tree_safe transliterates and sanitizes", {
  x <- c("São Tomé and Príncipe", "A  B", NA)
  res <- ncbimeta::make_tree_safe(x)

  testthat::expect_true(grepl("^Sao_Tome", res[1]))
  testthat::expect_equal(res[2], "A_B")
  testthat::expect_equal(res[3], "None")
})
