test_that(".od_request_with_variants returns first successful body", {
  skip_if_not_installed("mockery")

  calls <- integer(0)
  variants <- onedevr:::.od_request_with_variants
  mockery::stub(
    variants,
    "od_request",
    function(method, endpoint, query = NULL, body = NULL, conn = NULL) {
      calls <<- c(calls, length(calls) + 1L)
      if (identical(body, list(state = "Closed"))) {
        return(list(ok = TRUE, body = body))
      }
      stop("bad body", call. = FALSE)
    }
  )

  result <- variants(
    method = "POST",
    endpoint = "/issues/1/state-transitions",
    body_variants = list(
      list(transition = "Closed"),
      list(state = "Closed"),
      "Closed"
    ),
    conn = list()
  )
  expect_true(result$ok)
  expect_equal(result$body, list(state = "Closed"))
  expect_equal(length(calls), 2L)
})

test_that(".od_request_with_variants rethrows last error when all fail", {
  skip_if_not_installed("mockery")
  variants <- onedevr:::.od_request_with_variants
  mockery::stub(
    variants,
    "od_request",
    function(...) stop("nope", call. = FALSE)
  )
  expect_error(
    variants("POST", "/x", body_variants = list(list(a = 1), list(b = 2))),
    "nope"
  )
})

test_that("od_request builds URL and surfaces HTTP errors", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("httr2")

  # Use httr2's local/testing helpers via a mocked req_perform
  mockery::stub(
    od_request,
    "httr2::req_perform",
    function(req) {
      httr2::response(
        status_code = 404L,
        url = "https://git.example.test/~api/issues/1",
        method = "GET",
        headers = list("content-type" = "application/json"),
        body = charToRaw('{"message":"missing"}')
      )
    }
  )

  expect_error(
    od_request(
      "GET",
      "/issues/1",
      conn = list(
        api_base_url = "https://git.example.test/~api",
        token = "t",
        insecure_ssl = FALSE
      )
    ),
    "HTTP 404.*missing"
  )
})
