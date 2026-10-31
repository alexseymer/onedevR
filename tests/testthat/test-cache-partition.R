fake_json_response <- function(body = '{"ok":true}') {
  httr2::response(
    status_code = 200L,
    headers = list("Content-Type" = "application/json"),
    body = charToRaw(body)
  )
}

test_that(".od_cache_partition differs per credential and hides the secret", {
  a <- .od_cache_partition(list(host = "https://h", auth = "bearer", token = "tok-a"))
  b <- .od_cache_partition(list(host = "https://h", auth = "bearer", token = "tok-b"))
  expect_false(identical(a, b))
  expect_equal(a, .od_cache_partition(list(host = "https://h", auth = "bearer", token = "tok-a")))
  expect_false(grepl("tok-a", a, fixed = TRUE))
})

test_that("cached GET responses are not shared between credentials", {
  od_disable_cache()
  withr::defer(od_disable_cache())
  od_enable_cache(ttl_seconds = 60)

  performed <- 0L
  testthat::local_mocked_bindings(
    req_perform = function(req, ...) {
      performed <<- performed + 1L
      fake_json_response()
    },
    .package = "httr2"
  )

  conn_a <- list(host = "https://git.example.test", api_base_url = "https://git.example.test/~api",
                 auth = "bearer", token = "token-a")
  conn_b <- modifyList(conn_a, list(token = "token-b"))

  od_request("GET", "/users/me", conn = conn_a)
  od_request("GET", "/users/me", conn = conn_a)
  expect_equal(performed, 1L)

  od_request("GET", "/users/me", conn = conn_b)
  expect_equal(performed, 2L)
})

test_that("cache is bypassed for non-GET requests", {
  od_disable_cache()
  withr::defer(od_disable_cache())
  od_enable_cache(ttl_seconds = 60)

  performed <- 0L
  testthat::local_mocked_bindings(
    req_perform = function(req, ...) {
      performed <<- performed + 1L
      fake_json_response()
    },
    .package = "httr2"
  )
  conn <- list(host = "https://git.example.test", api_base_url = "https://git.example.test/~api",
               auth = "bearer", token = "token-a")
  od_request("POST", "/issues", body = list(title = "x"), conn = conn)
  od_request("POST", "/issues", body = list(title = "x"), conn = conn)
  expect_equal(performed, 2L)
})
