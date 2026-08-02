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
  mockery::stub(od_add_issue_comment, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/issue-comments")
    expect_equal(body$issueId, 283L)
    expect_equal(body$content, "note")
    list(id = 9)
  })
  expect_equal(od_add_issue_comment(145, "note", conn = list())$id, 9)
})
