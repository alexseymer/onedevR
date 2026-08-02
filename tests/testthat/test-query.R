test_that("od_paginate combines tibble pages", {
  pages <- list(
    tibble::tibble(id = 1:2, title = c("a", "b")),
    tibble::tibble(id = 3, title = "c"),
    tibble::tibble()
  )
  i <- 0L
  fetcher <- function(offset, count, as_tibble = NULL, ...) {
    i <<- i + 1L
    pages[[i]]
  }
  out <- od_paginate(fetcher, page_size = 2L)
  expect_s3_class(out, "tbl_df")
  expect_equal(out$id, 1:3)
})

test_that("od_get_query_description hits tod endpoints", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_query_description, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/tod/get-build-query-description")
    "grammar"
  })
  expect_equal(od_get_query_description("build", conn = list()), "grammar")
})
