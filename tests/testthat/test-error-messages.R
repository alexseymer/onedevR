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
