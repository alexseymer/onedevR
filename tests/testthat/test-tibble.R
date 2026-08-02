test_that("od_as_tibble converts list-of-objects to tibble", {
  skip_if_not_installed("tibble")

  items <- list(
    list(id = 1, number = 10, title = "a"),
    list(id = 2, number = 11, title = "b")
  )
  tb <- od_as_tibble(items)
  expect_s3_class(tb, "tbl_df")
  expect_equal(nrow(tb), 2L)
  expect_equal(tb$number, c(10, 11))

  expect_equal(od_as_tibble(items, as_tibble = FALSE), items)
  expect_equal(nrow(od_as_tibble(list())), 0L)
})

test_that("od_query_issues returns tibble by default", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("tibble")

  mockery::stub(od_query_issues, "od_request", function(...) {
    list(list(id = 1, number = 5, title = "x"))
  })

  out <- od_query_issues(state = "Open", conn = list())
  expect_s3_class(out, "tbl_df")
  expect_equal(out$number, 5)

  raw <- od_query_issues(state = "Open", as_tibble = FALSE, conn = list())
  expect_type(raw, "list")
  expect_equal(raw[[1]]$number, 5)
})
