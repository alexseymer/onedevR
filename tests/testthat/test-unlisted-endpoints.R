# Endpoints that the verified OneDev instance does not list in /~api/help.
# A failure there gets a hint; other errors are passed on unchanged.

.http_error <- function(status) {
  rlang::catch_cnd(rlang::abort(
    sprintf("OneDev API request failed [HTTP %d]: nope", status),
    class = "od_http_error", status = status, method = "GET", url = "https://x/~api/y"
  ))
}

test_that(".od_request_unlisted passes a successful answer through", {
  fake <- function(method, endpoint, ..., conn = NULL) list(ok = TRUE, method = method, endpoint = endpoint)
  out <- .od_request_unlisted("GET", "/a", conn = list(), request = fake)
  expect_equal(out$endpoint, "/a")
})

test_that(".od_request_unlisted adds a hint to HTTP 404 and 405 and keeps the class", {
  for (status in c(404L, 405L)) {
    fake <- function(...) stop(.http_error(status))
    err <- expect_error(
      .od_request_unlisted("POST", "/x/y", conn = list(), request = fake),
      class = "od_http_error"
    )
    expect_match(conditionMessage(err), sprintf("[HTTP %d]", status), fixed = TRUE)
    expect_match(conditionMessage(err), "POST /x/y is not in the REST API description", fixed = TRUE)
    expect_match(conditionMessage(err), "/~api/help", fixed = TRUE)
    expect_equal(err$status, status)
  }
})

test_that(".od_request_unlisted leaves other errors alone", {
  fake <- function(...) stop(.http_error(500L))
  err <- expect_error(.od_request_unlisted("GET", "/x", conn = list(), request = fake), class = "od_http_error")
  expect_false(grepl("hint:", conditionMessage(err), fixed = TRUE))
  plain <- function(...) stop("network down")
  expect_error(.od_request_unlisted("GET", "/x", conn = list(), request = plain), "network down")
})

test_that("functions for unlisted endpoints report the hint on HTTP 404", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_webhook, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_webhook, "od_request", function(...) stop(.http_error(404L)))
  expect_error(od_get_webhook(3, conn = list()), "GET /projects/20/webhooks/3 is not in the REST API description")

  mockery::stub(od_get_commit_statuses, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_commit_statuses, "od_request", function(...) stop(.http_error(404L)))
  expect_error(od_get_commit_statuses("abc123", conn = list()), "is not in the REST API description")
})
