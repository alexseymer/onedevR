test_that(".od_get_list makes one call for 100 or fewer records", {
  calls <- list()
  fake <- function(method, endpoint, query = NULL, conn = NULL) {
    calls[[length(calls) + 1L]] <<- query
    lapply(seq_len(query$count), function(i) list(id = i))
  }
  out <- .od_get_list("/issues", query = "q", count = 5L, offset = 2L, conn = list(), request = fake)
  expect_length(out, 5)
  expect_length(calls, 1)
  expect_equal(calls[[1]]$count, 5L)
  expect_equal(calls[[1]]$offset, 2L)
  expect_equal(calls[[1]]$query, "q")
})

test_that(".od_get_list pages in steps of 100 for larger counts", {
  calls <- list()
  fake <- function(method, endpoint, query = NULL, conn = NULL) {
    calls[[length(calls) + 1L]] <<- query
    lapply(seq_len(query$count), function(i) list(id = query$offset + i))
  }
  out <- .od_get_list("/issues", count = 250L, offset = 10L, conn = list(), request = fake)
  expect_length(out, 250)
  expect_equal(vapply(calls, function(q) q$count, integer(1)), c(100L, 100L, 50L))
  expect_equal(vapply(calls, function(q) q$offset, integer(1)), c(10L, 110L, 210L))
  expect_equal(out[[250]]$id, 260L)
})

test_that(".od_get_list stops when the server runs out of records", {
  pages <- 0L
  fake <- function(method, endpoint, query = NULL, conn = NULL) {
    pages <<- pages + 1L
    if (pages == 1L) lapply(1:100, function(i) list(id = i)) else lapply(1:30, function(i) list(id = 100 + i))
  }
  out <- .od_get_list("/issues", count = 500L, conn = list(), request = fake)
  expect_length(out, 130)
  expect_equal(pages, 2L)
})

test_that(".od_get_list validates count and offset", {
  expect_error(.od_get_list("/x", count = 0L, request = function(...) list()), "positive")
  expect_error(.od_get_list("/x", count = NA, request = function(...) list()), "positive")
  expect_error(.od_get_list("/x", offset = -1L, request = function(...) list()), "non-negative")
})

test_that("od_query_issues pages when count exceeds 100", {
  skip_if_not_installed("mockery")
  seen <- integer()
  mockery::stub(od_query_issues, "od_request", function(method, endpoint, query = NULL, ...) {
    seen <<- c(seen, query$count)
    lapply(seq_len(query$count), function(i) list(id = i))
  })
  res <- od_query_issues(state = "Open", count = 150L, as_tibble = FALSE, conn = list())
  expect_length(res, 150)
  expect_equal(seen, c(100L, 50L))
})
