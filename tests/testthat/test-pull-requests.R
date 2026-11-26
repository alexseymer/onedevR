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

# Helper: a stubbed copy of od_add_pull_request_comment (`$f`) that records the
# request body (`$sent`). mockery::stub() changes the function in the calling
# frame, so the copy is built here and returned.
.pr_comment_stubs <- function(get_me = function(conn = NULL) list(id = 42, name = "alex"),
                              whoami = function(conn = NULL) "alex",
                              resolve = function(user, ...) if (user == "alex") "42" else "7") {
  env <- new.env(parent = emptyenv())
  env$sent <- NULL
  f <- od_add_pull_request_comment
  mockery::stub(f, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(f, "od_get_me", function(...) get_me(...))
  mockery::stub(f, "od_whoami", function(...) whoami(...))
  mockery::stub(f, "od_resolve_user_id", function(...) resolve(...))
  mockery::stub(f, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/pull-request-comments")
    env$sent <- body
    list(id = 3)
  })
  env$f <- f
  env
}

test_that("od_add_pull_request_comment sends the current user as author", {
  skip_if_not_installed("mockery")
  env <- .pr_comment_stubs()
  expect_equal(env$f(42, "looks good", conn = list())$id, 3)
  # Without userId OneDev answers HTTP 500 (verified live)
  expect_equal(env$sent$requestId, 900L)
  expect_equal(env$sent$content, "looks good")
  expect_equal(env$sent$userId, 42L)
})

test_that("od_add_pull_request_comment sends an explicit user and takes conn as third argument", {
  skip_if_not_installed("mockery")
  env <- .pr_comment_stubs()
  env$f(42, "x", user = "bob", conn = list())
  expect_equal(env$sent$userId, 7L)
  env$f(42, "x", list(host = "https://onedev.example.org"))
  expect_equal(env$sent$userId, 42L)
})

test_that("od_add_pull_request_comment sends no userId when the current user is unknown", {
  skip_if_not_installed("mockery")
  env <- .pr_comment_stubs(
    get_me = function(conn = NULL) stop("HTTP 403"),
    whoami = function(conn = NULL) stop("no identity")
  )
  env$f(42, "x", conn = list())
  expect_null(env$sent$userId)
  expect_equal(env$sent$requestId, 900L)
})

test_that("od_add_pull_request_comment rejects an invalid user and fails for an unknown explicit user", {
  skip_if_not_installed("mockery")
  env <- .pr_comment_stubs(resolve = function(user, ...) stop("no such user"))
  expect_error(env$f(42, "x", user = NA, conn = list()), "`user` must be")
  expect_error(env$f(42, "x", user = "ghost", conn = list()), "no such user")
  expect_null(env$sent)
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

test_that("od_get_pull_request_issues returns the ids of the issues the PR fixes", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_pull_request_issues, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_get_pull_request_issues, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/pulls/900/fixed-issue-ids")
    list(145L, 146L)
  })
  ids <- od_get_pull_request_issues(42, as_tibble = FALSE, conn = list())
  expect_equal(ids, list(145L, 146L))
  tbl <- od_get_pull_request_issues(42, as_tibble = TRUE, conn = list())
  expect_s3_class(tbl, "tbl_df")
  expect_equal(tbl$id, c(145L, 146L))
})

test_that("od_get_pull_request_issues returns an empty result when no issue is fixed", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_pull_request_issues, "od_resolve_pull_request_id", function(...) "900")
  mockery::stub(od_get_pull_request_issues, "od_request", function(...) list())
  expect_equal(od_get_pull_request_issues(42, as_tibble = FALSE, conn = list()), list())
  tbl <- od_get_pull_request_issues(42, as_tibble = TRUE, conn = list())
  expect_equal(nrow(tbl), 0L)
  expect_named(tbl, "id")
})
