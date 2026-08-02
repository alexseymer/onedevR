test_that("od_query_pull_requests forwards query params", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  mockery::stub(
    od_query_pull_requests,
    "od_request",
    function(method, endpoint, query = NULL, body = NULL, conn = NULL) {
      captured$method <- method
      captured$endpoint <- endpoint
      captured$query <- query
      list()
    }
  )

  od_query_pull_requests(query = 'Open', count = 5L, offset = 2L, conn = list())
  expect_equal(captured$method, "GET")
  expect_equal(captured$endpoint, "/pulls")
  expect_equal(captured$query$query, "Open")
  expect_equal(captured$query$count, 5L)
  expect_equal(captured$query$offset, 2L)
})

test_that("od_get_pull_request resolves UI number then GETs", {
  skip_if_not_installed("mockery")
  mockery::stub(
    od_get_pull_request,
    "od_resolve_pull_request_id",
    function(pull_request_number, conn = NULL) {
      expect_equal(pull_request_number, 42)
      "900"
    }
  )
  mockery::stub(od_get_pull_request, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/pulls/900")
    list(id = 900, number = 42, title = "Fix things")
  })

  pr <- od_get_pull_request(42, conn = list())
  expect_equal(pr$title, "Fix things")
})

test_that("od_get_pull_request_comments and reviews hit nested endpoints", {
  skip_if_not_installed("mockery")

  mockery::stub(od_get_pull_request_comments, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_get_pull_request_comments, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/comments")
    list(list(id = 1, content = "lgtm"))
  })
  comments <- od_get_pull_request_comments(42, conn = list())
  expect_equal(comments[[1]]$content, "lgtm")

  mockery::stub(od_get_pull_request_reviews, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_get_pull_request_reviews, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/reviews")
    list(list(status = "APPROVED"))
  })
  reviews <- od_get_pull_request_reviews(42, conn = list())
  expect_equal(reviews[[1]]$status, "APPROVED")
})
