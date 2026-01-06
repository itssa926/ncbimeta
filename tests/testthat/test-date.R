test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

testthat::test_that("standardize_date handles year/month/day/missing", {
  x <- c("['2020']", "2020-07", "2020-07-03", "None")
  res <- ncbimeta::standardize_date(x)

  testthat::expect_equal(res$date_std[1], "2020-??-??")
  testthat::expect_equal(res$date_granularity[1], "year")

  testthat::expect_equal(res$date_std[2], "2020-07-??")
  testthat::expect_equal(res$date_granularity[2], "month")

  testthat::expect_equal(res$date_std[3], "2020-07-03")
  testthat::expect_equal(res$date_granularity[3], "day")

  testthat::expect_true(is.na(res$date_std[4]))
  testthat::expect_equal(res$date_granularity[4], "unknown")
})
