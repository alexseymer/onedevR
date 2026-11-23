test_that("od_list_iterations GETs project iterations with paging", {
  skip_if_not_installed("mockery")

  mockery::stub(od_list_iterations, "od_resolve_project_id", function(project = NULL, conn = NULL) {
    expect_equal(project, "group/project")
    "20"
  })
  mockery::stub(od_list_iterations, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/projects/20/iterations")
    expect_equal(query$count, 100L)
    expect_equal(query$offset, 0L)
    list(list(id = 17L, name = "Version 2.x"))
  })

  result <- od_list_iterations("group/project", conn = list())
  expect_s3_class(result, "tbl_df")
  expect_equal(result$id, 17L)
})

test_that("od_add_issue_iterations posts the ids as a JSON array", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_issue_iterations, "od_resolve_issue_id", function(...) "283")
  sent <- NULL
  mockery::stub(
    od_add_issue_iterations,
    "od_request",
    function(method, endpoint, body = NULL, conn = NULL, ...) {
      expect_equal(method, "POST")
      expect_equal(endpoint, "/issues/283/iterations")
      sent <<- body
      list(ok = TRUE)
    }
  )

  expect_equal(od_add_issue_iterations(145, c(17L, 18L), conn = list())$ok, TRUE)
  expect_equal(sent, list(17L, 18L))
  # A single id must stay an array, not become a bare number.
  od_add_issue_iterations(145, 17L, conn = list())
  expect_equal(as.character(jsonlite::toJSON(sent, auto_unbox = TRUE)), "[17]")
})

test_that("od_add_issue_iterations reports the one request error without variant noise", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_issue_iterations, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_add_issue_iterations, "od_request", function(...) stop("HTTP 400 bad id"))
  err <- expect_error(od_add_issue_iterations(145, 17L, conn = list()), "HTTP 400 bad id")
  expect_false(grepl("All request body variants", conditionMessage(err)))
})

test_that("od_add_issue_iterations rejects empty ids", {
  expect_error(
    od_add_issue_iterations(1, integer(), conn = list()),
    "at least one id"
  )
})

test_that("od_resolve_iteration_ids maps names, passes ids, errors on unknown", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_iteration_ids, "od_list_iterations", function(...) {
    list(list(id = 17L, name = "Version 3.0.0"), list(id = 18L, name = "Version 2.X.X"))
  })
  expect_equal(od_resolve_iteration_ids(c("Version 2.X.X", 5L), conn = list()), c(18L, 5L))
  expect_equal(od_resolve_iteration_ids(NULL), integer(0))
  expect_error(
    od_resolve_iteration_ids("Pipelines", conn = list()),
    "Iteration not found: Pipelines. Available: Version 3.0.0, Version 2.X.X"
  )
})

test_that("od_get_iteration resolves by name and by id", {
  skip_if_not_installed("mockery")

  sample <- list(
    list(id = 17L, name = "Sprint 5"),
    list(id = 18L, name = "Sprint 6")
  )
  mockery::stub(od_get_iteration, "od_list_iterations", function(...) sample)

  by_name <- od_get_iteration("Sprint 5", conn = list())
  expect_equal(by_name$id, 17L)

  by_id <- od_get_iteration(18L, conn = list())
  expect_equal(by_id$name, "Sprint 6")

  expect_error(od_get_iteration("Missing", conn = list()), "was not found")
})
