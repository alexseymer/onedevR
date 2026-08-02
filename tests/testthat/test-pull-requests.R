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
  expect_equal(comments$content, "lgtm")

  mockery::stub(od_get_pull_request_reviews, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_get_pull_request_reviews, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/reviews")
    list(list(status = "APPROVED"))
  })
  reviews <- od_get_pull_request_reviews(42, conn = list())
  expect_equal(reviews$status, "APPROVED")
})

test_that("od_create_pull_request posts expected body", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_pull_request, "od_resolve_project_id", function(project = NULL, conn = NULL) "20")
  mockery::stub(od_create_pull_request, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/pulls")
    expect_equal(body$targetProjectId, 20L)
    expect_equal(body$sourceProjectId, 20L)
    expect_equal(body$sourceBranch, "feature")
    expect_equal(body$targetBranch, "main")
    expect_equal(body$title, "Add feature")
    list(id = 1, number = 9)
  })
  created <- od_create_pull_request(
    title = "Add feature",
    source_branch = "feature",
    conn = list()
  )
  expect_equal(created$number, 9)
})

test_that("od_add_pull_request_comment posts to pull-request-comments", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_pull_request_comment, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_add_pull_request_comment, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(endpoint, "/pull-request-comments")
    expect_equal(body$requestId, 900L)
    expect_equal(body$content, "looks good")
    list(id = 3)
  })
  expect_equal(od_add_pull_request_comment(42, "looks good", conn = list())$id, 3)
})

test_that("PR review actions hit approve/request/merge/discard endpoints", {
  skip_if_not_installed("mockery")

  mockery::stub(od_approve_pull_request, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_approve_pull_request, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/approve")
    list(ok = TRUE)
  })
  expect_true(od_approve_pull_request(42, conn = list())$ok)

  mockery::stub(od_request_pull_request_changes, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_request_pull_request_changes, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/request-for-changes")
    list(ok = TRUE)
  })
  expect_true(od_request_pull_request_changes(42, conn = list())$ok)

  mockery::stub(od_merge_pull_request, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_merge_pull_request, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/merge")
    list(ok = TRUE)
  })
  expect_true(od_merge_pull_request(42, conn = list())$ok)

  mockery::stub(od_discard_pull_request, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_discard_pull_request, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/pulls/900/discard")
    list(ok = TRUE)
  })
  expect_true(od_discard_pull_request(42, conn = list())$ok)
})
