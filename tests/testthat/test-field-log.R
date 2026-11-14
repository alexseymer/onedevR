# Regression tests for problems seen in real use against a OneDev instance
# (field log). Each test names the symptom so a future failure is easy to trace.

conn <- list(
  host = "https://git.example.test",
  api_base_url = "https://git.example.test/~api",
  auth = "bearer",
  token = "t"
)

test_that("non-ASCII characters survive in request bodies (arrow became '?')", {
  captured <- NULL
  testthat::local_mocked_bindings(
    req_perform = function(req, ...) {
      captured <<- req
      httr2::response(
        status_code = 200L,
        headers = list("Content-Type" = "application/json"),
        body = charToRaw("{}")
      )
    },
    .package = "httr2"
  )
  title <- "Splash: Prod→Dev-Sync für start_dev"
  od_request("POST", "/issues/1/title", body = title, conn = conn)
  sent <- rawToChar(captured$body$data)
  Encoding(sent) <- "UTF-8"
  expect_equal(sent, jsonlite::toJSON(title, auto_unbox = TRUE) |> as.character())
  expect_true(grepl("→", sent, fixed = TRUE))
})

test_that("state names with spaces are quoted in the query (In Progress -> 406)", {
  skip_if_not_installed("mockery")
  seen <- NULL
  mockery::stub(od_query_issues, "od_request", function(method, endpoint, query = NULL, ...) {
    seen <<- query$query
    list()
  })
  od_query_issues(state = "In Progress", count = 20L, conn = list())
  expect_equal(seen, '"State" is "In Progress"')
})

test_that("merge-conflict errors keep the server message (PR merge 406)", {
  resp <- httr2::response(
    status_code = 406L,
    headers = list("Content-Type" = "text/plain"),
    body = charToRaw("There are merge conflicts")
  )
  expect_error(
    .od_http_error(resp, "There are merge conflicts", method = "POST"),
    "HTTP 406\\]: There are merge conflicts"
  )
})

test_that("unrecognized-field errors keep the server message (comment body 400)", {
  msg <- 'Unrecognized field "issue" (class io.onedev.server.model.IssueComment)'
  resp <- httr2::response(
    status_code = 400L,
    headers = list("Content-Type" = "text/plain"),
    body = charToRaw(msg)
  )
  expect_error(.od_http_error(resp, msg), "HTTP 400\\]: Unrecognized field")
})

test_that("a state transition that fails on every body reports all errors (Done -> 400)", {
  skip_if_not_installed("mockery")
  mockery::stub(od_issue_transition_state, "od_resolve_issue_id", function(...) "283")
  mockery::stub(od_issue_transition_state, ".od_request_with_variants", function(method, endpoint, body_variants, conn = NULL) {
    expect_length(body_variants, 3L)
    stop("All request body variants failed:\n1. HTTP 400 StateTransitionData", call. = FALSE)
  })
  expect_error(
    od_issue_transition_state(252, "Done", conn = list()),
    "All request body variants failed"
  )
})

test_that("a named iteration that does not exist lists the available ones", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_iteration_ids, "od_list_iterations", function(...) {
    list(list(id = 1L, name = "Version 3.0.0"), list(id = 2L, name = "Version 2.X.X"))
  })
  expect_error(
    od_resolve_iteration_ids("Pipelines", conn = list()),
    "Iteration not found: Pipelines. Available: Version 3.0.0, Version 2.X.X"
  )
})

test_that("an unknown query field gets the invalid-query hint (IsResolved -> 406)", {
  resp <- httr2::response(
    status_code = 406L,
    headers = list("Content-Type" = "text/plain"),
    body = charToRaw("Invalid query")
  )
  expect_error(
    .od_http_error(resp, "Invalid query"),
    "Invalid query.*od_get_query_description"
  )
})
