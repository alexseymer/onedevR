test_that(".od_normalize_collection handles shapes", {
  norm <- onedevr:::.od_normalize_collection
  expect_equal(norm(NULL), list())
  expect_equal(norm(list(items = list(list(id = 1)))), list(list(id = 1)))
  expect_equal(norm(list(data = list(list(id = 2)))), list(list(id = 2)))
  expect_equal(norm(list(id = 3, title = "x")), list(list(id = 3, title = "x")))
})

test_that("od_query_issues builds state clause and default state", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  mockery::stub(od_query_issues, "od_request", function(method, endpoint, query = NULL, body = NULL, conn = NULL) {
    captured$method <- method
    captured$endpoint <- endpoint
    captured$query <- query
    list()
  })

  od_query_issues(
    state = "Open",
    count = 10L,
    conn = list(default_issue_state = "Closed")
  )
  expect_equal(captured$method, "GET")
  expect_equal(captured$endpoint, "/issues")
  expect_equal(captured$query$query, '"State" is "Open"')
  expect_equal(captured$query$count, 10L)

  od_query_issues(conn = list(default_issue_state = "Open"))
  expect_equal(captured$query$query, '"State" is "Open"')

  od_query_issues(query = '"Type" is "Bug"', state = "Open", conn = list())
  expect_equal(captured$query$query, '("Type" is "Bug") and "State" is "Open"')
})

test_that("od_get_issue resolves UI number then GETs internal id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_issue, "od_resolve_issue_id", function(issue_number, conn = NULL) {
    expect_equal(issue_number, 145)
    "283"
  })
  mockery::stub(od_get_issue, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/issues/283")
    list(id = 283, number = 145, title = "hello")
  })
  issue <- od_get_issue(145, conn = list())
  expect_equal(issue$title, "hello")
})

test_that("od_create_issue uses project id and tries variants", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_issue, "od_resolve_project_id", function(project = NULL, conn = NULL) "20")

  mockery::stub(od_create_issue, ".od_request_with_variants", function(method, endpoint, body_variants, conn = NULL) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/issues")
    expect_equal(body_variants[[1]]$projectId, 20L)
    expect_equal(body_variants[[1]]$title, "API test")
    expect_equal(body_variants[[1]]$fields$Priority, "Normal")
    expect_null(body_variants[[1]]$iterationIds)
    expect_equal(body_variants[[2]]$project$id, 20L)
    list(id = 1, number = 10, title = "API test")
  })

  created <- od_create_issue(
    title = "API test",
    description = "Created from R",
    fields = list(Priority = "Normal"),
    conn = list()
  )
  expect_equal(created$number, 10)
})

test_that("od_create_issue includes iterationIds when given", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_issue, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_create_issue, ".od_request_with_variants", function(method, endpoint, body_variants, conn = NULL) {
    expect_equal(body_variants[[1]]$iterationIds, list(17L, 18L))
    expect_equal(body_variants[[2]]$iterationIds, list(17L, 18L))
    list(id = 2, number = 11)
  })

  created <- od_create_issue(
    title = "With iterations",
    iteration_ids = c(17L, 18L),
    conn = list()
  )
  expect_equal(created$number, 11)
})

test_that("od_create_issue fetches the issue when OneDev answers with the internal id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_issue, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_create_issue, ".od_request_with_variants", function(...) 101L)
  fetched <- NULL
  mockery::stub(od_create_issue, "od_get_issue", function(issue_number, conn = NULL, use_internal_id = FALSE) {
    fetched <<- list(id = issue_number, internal = use_internal_id)
    list(id = 101, number = 12, title = "API test")
  })

  created <- od_create_issue(title = "API test", conn = list())
  expect_equal(fetched, list(id = "101", internal = TRUE))
  expect_equal(created$number, 12)
  expect_equal(created$title, "API test")
})

test_that("od_create_issue warns and returns the id when fetching the created issue fails", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_issue, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_create_issue, ".od_request_with_variants", function(...) 101L)
  mockery::stub(od_create_issue, "od_get_issue", function(...) stop("HTTP 504"))

  expect_warning(
    created <- od_create_issue(title = "API test", conn = list()),
    "internal id 101.*HTTP 504.*Do not retry"
  )
  expect_equal(created, list(id = 101L))
})

test_that("od_create_issue does not fetch for a response that is not an internal id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_issue, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_create_issue, "od_get_issue", function(...) stop("must not be called"))
  for (answer in list("", "abc", NA_character_)) {
    mockery::stub(od_create_issue, ".od_request_with_variants", function(...) answer)
    expect_identical(od_create_issue(title = "API test", conn = list()), answer)
  }
})

test_that("od_get_issue_fields resolves UI number then GETs fields", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_issue_fields, "od_resolve_issue_id", function(issue_number, conn = NULL) {
    expect_equal(issue_number, 145)
    "283"
  })
  mockery::stub(od_get_issue_fields, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/issues/283/fields")
    list(Assignee = "developer", Type = "Task")
  })

  fields <- od_get_issue_fields(145, conn = list())
  expect_equal(fields$Assignee, "developer")
  expect_equal(fields$Type, "Task")
})

test_that("od_issue_set_title passes raw string body first", {
  skip_if_not_installed("mockery")
  mockery::stub(od_issue_set_title, "od_resolve_issue_id", function(...) "283")
  mockery::stub(
    od_issue_set_title,
    ".od_request_with_variants",
    function(method, endpoint, body_variants, conn = NULL) {
      expect_equal(method, "POST")
      expect_equal(endpoint, "/issues/283/title")
      expect_equal(body_variants[[1]], "New title")
      expect_equal(body_variants[[2]], list(title = "New title"))
      list(ok = TRUE)
    }
  )
  expect_true(od_issue_set_title(145, "New title", conn = list())$ok)
})

test_that("od_issue_set_description passes raw string body first", {
  skip_if_not_installed("mockery")
  mockery::stub(od_issue_set_description, "od_resolve_issue_id", function(...) "283")
  mockery::stub(
    od_issue_set_description,
    ".od_request_with_variants",
    function(method, endpoint, body_variants, conn = NULL) {
      expect_equal(method, "POST")
      expect_equal(endpoint, "/issues/283/description")
      expect_equal(body_variants[[1]], "Updated body")
      expect_equal(body_variants[[2]], list(description = "Updated body"))
      list(ok = TRUE)
    }
  )
  expect_true(od_issue_set_description(145, "Updated body", conn = list())$ok)
})

test_that("od_issue_transition_state tries three body variants", {
  skip_if_not_installed("mockery")
  mockery::stub(od_issue_transition_state, "od_resolve_issue_id", function(...) "283")
  mockery::stub(
    od_issue_transition_state,
    ".od_request_with_variants",
    function(method, endpoint, body_variants, conn = NULL) {
      expect_equal(method, "POST")
      expect_equal(endpoint, "/issues/283/state-transitions")
      expect_equal(body_variants[[1]], list(state = "Closed"))
      expect_equal(body_variants[[2]], list(transition = "Closed"))
      expect_equal(body_variants[[3]], "Closed")
      list(ok = TRUE)
    }
  )
  expect_equal(
    od_issue_transition_state(145, "Closed", conn = list())$ok,
    TRUE
  )
})

test_that("od_issue_set_fields requires named list", {
  expect_error(od_issue_set_fields(1, list(1), conn = list()), "named list")
})

test_that("od_get_issue_comments and od_add_issue_comment", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_issue_comments, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_get_issue_comments, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/issues/283/comments")
    list(list(id = 1, content = "hi"))
  })
  expect_equal(od_get_issue_comments(145, conn = list())$content, "hi")
  expect_equal(
    od_get_issue_comments(145, as_tibble = FALSE, conn = list())[[1]]$content,
    "hi"
  )
  mockery::stub(od_add_issue_comment, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_add_issue_comment, "od_get_me", function(conn = NULL) stop("HTTP 403"))
  mockery::stub(od_add_issue_comment, "od_whoami", function(conn = NULL) stop("no identity"))
  mockery::stub(od_add_issue_comment, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/issue-comments")
    expect_named(body, c("issueId", "content"))
    expect_equal(body$issueId, 283L)
    expect_equal(body$content, "note")
    list(id = 9)
  })
  expect_equal(od_add_issue_comment(145, "note", conn = list())$id, 9)
})

# Helper: a stubbed copy of od_add_issue_comment (`$f`) that records the request
# body (`$sent`) and the number of lookups made to find the author (`$lookups`).
# mockery::stub() changes the function in the calling frame, so the copy is
# built here and returned.
.comment_stubs <- function(get_me = function(conn = NULL) list(id = 42, name = "alex"),
                           whoami = function(conn = NULL) "alex",
                           resolve = function(user, ...) if (user == "alex") "42" else "7") {
  env <- new.env(parent = emptyenv())
  env$sent <- NULL
  env$lookups <- 0L
  f <- od_add_issue_comment
  mockery::stub(f, "od_resolve_issue_id", function(...) "283")
  mockery::stub(f, "od_get_me", function(...) {
    env$lookups <- env$lookups + 1L
    get_me(...)
  })
  mockery::stub(f, "od_whoami", function(...) {
    env$lookups <- env$lookups + 1L
    whoami(...)
  })
  mockery::stub(f, "od_resolve_user_id", function(...) {
    env$lookups <- env$lookups + 1L
    resolve(...)
  })
  mockery::stub(f, "od_request", function(method, endpoint, body = NULL, ...) {
    env$sent <- body
    list(id = 9)
  })
  env$f <- f
  env
}

test_that("od_add_issue_comment defaults the author to the current user with one lookup", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs()

  env$f(145, "note", conn = list())
  expect_equal(env$sent$userId, 42L)
  expect_equal(env$sent$issueId, 283L)
  expect_equal(env$sent$content, "note")
  expect_equal(env$lookups, 1L)  # GET /users/me only, no second id lookup

  env$f(145, "note", user = NULL, conn = list())
  expect_equal(env$sent$userId, 42L)
})

test_that("od_add_issue_comment falls back to the login name when /users/me is refused", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs(get_me = function(conn = NULL) stop("HTTP 403"))
  env$f(145, "note", conn = list())
  expect_equal(env$sent$userId, 42L)
})

test_that("od_add_issue_comment sends an explicit user", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs()
  env$f(145, "note", user = "bob", conn = list())
  expect_equal(env$sent$userId, 7L)
  env$f(145, "note", user = 7, conn = list())
  expect_equal(env$sent$userId, 7L)
})

test_that("od_add_issue_comment takes conn as the third positional argument", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs()
  # Argument order of 0.7.1: (issue_number, content, conn). The connection must
  # not be mistaken for the author.
  conn <- list(host = "https://onedev.example.org", token = "x")
  env$f(145, "note", conn)
  expect_equal(env$sent$userId, 42L)
})

test_that("od_add_issue_comment sends no userId when the current user is unknown", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs(
    get_me = function(conn = NULL) stop("HTTP 403"),
    whoami = function(conn = NULL) stop("no identity")
  )
  env$f(145, "note", conn = list())
  expect_null(env$sent$userId)
  expect_equal(env$sent$issueId, 283L)
})

test_that("od_add_issue_comment sends no userId when the default author cannot be resolved", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs(
    get_me = function(conn = NULL) stop("HTTP 403"),
    resolve = function(user, ...) stop("HTTP 403 on /users/ids")
  )
  env$f(145, "note", conn = list())
  expect_null(env$sent$userId)
})

test_that("od_add_issue_comment fails for an explicit user that cannot be resolved", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs(resolve = function(user, ...) stop("no such user"))
  expect_error(env$f(145, "note", user = "ghost", conn = list()), "no such user")
  expect_null(env$sent)
})

test_that("od_add_issue_comment rejects an invalid user", {
  skip_if_not_installed("mockery")
  env <- .comment_stubs()
  expect_error(env$f(145, "note", user = NA, conn = list()), "`user` must be")
  expect_error(env$f(145, "note", user = c("a", "b"), conn = list()), "`user` must be")
  expect_error(env$f(145, "note", user = list(1), conn = list()), "`user` must be")
  expect_null(env$sent)
})

test_that("od_link_issue_to_pull_request creates correct endpoint", {
  skip_if_not_installed("mockery")
  mockery::stub(od_link_issue_to_pull_request, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_link_issue_to_pull_request, "od_resolve_pull_request_id", function(...) "456")
  mockery::stub(od_link_issue_to_pull_request, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/issues/283/pull-requests")
    expect_equal(body$pullRequestId, 456L)
    list(ok = TRUE)
  })
  result <- od_link_issue_to_pull_request(145, 42, conn = list())
  expect_equal(result$ok, TRUE)
})

test_that("od_get_issue_pull_requests retrieves linked PRs", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_issue_pull_requests, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_get_issue_pull_requests, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/issues/283/pull-requests")
    list(list(number = 42, title = "Fix issue"), list(number = 43, title = "Update"))
  })
  prs <- od_get_issue_pull_requests(145, as_tibble = FALSE, conn = list())
  expect_equal(length(prs), 2)
  expect_equal(prs[[1]]$number, 42)
})

test_that("od_unlink_issue_from_pull_request removes link", {
  skip_if_not_installed("mockery")
  mockery::stub(od_unlink_issue_from_pull_request, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_unlink_issue_from_pull_request, "od_resolve_pull_request_id", function(...) "456")
  mockery::stub(od_unlink_issue_from_pull_request, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "DELETE")
    expect_equal(endpoint, "/issues/283/pull-requests/456")
    NULL
  })
  result <- od_unlink_issue_from_pull_request(145, 42, conn = list())
  expect_null(result)
})
