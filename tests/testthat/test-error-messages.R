mk_resp <- function(status, body, type = "text/html") {
  httr2::response(
    status_code = status,
    headers = list("Content-Type" = type),
    body = charToRaw(body)
  )
}

test_that("HTML error pages are reduced to their title", {
  html <- "<html><head><title>Interner Fehler</title></head><body><h1>x</h1><pre>stack...</pre></body></html>"
  expect_error(
    .od_http_error(mk_resp(500L, html), html),
    "HTTP 500\\]: HTML error page: Interner Fehler"
  )
})

test_that("HTML without a title is stripped of tags", {
  html <- "<html><body><p>Something   broke</p></body></html>"
  err <- tryCatch(.od_http_error(mk_resp(500L, html), html), error = conditionMessage)
  expect_match(err, "Something broke")
  expect_false(grepl("<", err, fixed = TRUE))
})

test_that("very long messages are truncated", {
  long <- strrep("x", 1000)
  err <- tryCatch(.od_http_error(mk_resp(500L, long, "text/plain"), long), error = conditionMessage)
  expect_lt(nchar(err), 400)
  expect_match(err, "\\.\\.\\.$")
})

test_that("count limit errors get a paging hint", {
  msg <- "Count should not be greater than 100"
  expect_error(
    .od_http_error(mk_resp(406L, msg, "text/plain"), msg),
    "Count should not be greater than 100.*offset"
  )
})

test_that("JSON error messages are unchanged", {
  payload <- list(message = "Issue not found")
  expect_error(
    .od_http_error(mk_resp(404L, "{}", "application/json"), payload),
    "HTTP 404\\]: Issue not found"
  )
})

test_that("HTTP errors are od_http_error conditions with status, method and url", {
  resp <- httr2::response(
    status_code = 403L,
    url = "https://git.example.test/~api/users/me",
    headers = list("Content-Type" = "application/json"),
    body = charToRaw('{"message":"Forbidden"}')
  )
  e <- tryCatch(
    .od_http_error(resp, list(message = "Forbidden"), method = "GET"),
    error = function(e) e
  )
  expect_s3_class(e, "od_http_error")
  expect_s3_class(e, "error")
  expect_equal(e$status, 403L)
  expect_equal(e$method, "GET")
  expect_equal(e$url, "https://git.example.test/~api/users/me")
  expect_match(conditionMessage(e), "HTTP 403\\]: Forbidden")
})

test_that("callers can branch on the condition class", {
  resp <- mk_resp(500L, "<html><title>Interner Fehler</title></html>")
  out <- tryCatch(
    .od_http_error(resp, "<html><title>Interner Fehler</title></html>"),
    od_http_error = function(e) e$status
  )
  expect_equal(out, 500L)
})
