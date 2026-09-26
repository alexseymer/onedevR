test_that("od_set_commit_status sends required fields", {
  skip_if_not_installed("mockery")
  mockery::stub(od_set_commit_status, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_set_commit_status, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/repositories/20/commits/abc123/statuses")
    expect_equal(body$state, "success")
    expect_equal(body$context, "ci/build")
    list(state = "success", context = "ci/build")
  })
  result <- od_set_commit_status(
    "abc123",
    state = "success",
    context = "ci/build",
    conn = list()
  )
  expect_equal(result$state, "success")
})

test_that("od_set_commit_status includes optional fields", {
  skip_if_not_installed("mockery")
  mockery::stub(od_set_commit_status, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_set_commit_status, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(body$description, "Build passed")
    expect_equal(body$targetUrl, "https://example.com/build/123")
    list(ok = TRUE)
  })
  od_set_commit_status(
    "abc123",
    state = "success",
    context = "ci/build",
    description = "Build passed",
    target_url = "https://example.com/build/123",
    conn = list()
  )
})

test_that("od_get_commit_statuses retrieves statuses", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_commit_statuses, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_commit_statuses, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/repositories/20/commits/abc123/statuses")
    list(
      list(state = "success", context = "ci/build"),
      list(state = "success", context = "coverage/check")
    )
  })
  statuses <- od_get_commit_statuses("abc123", conn = list())
  expect_equal(nrow(statuses), 2)
  expect_equal(statuses$context[[1]], "ci/build")
})
