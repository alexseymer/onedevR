conn <- list(host = "https://git.example.test", api_base_url = "https://git.example.test/~api")

test_that("absolute URLs on the configured origin are allowed", {
  expect_equal(
    .od_resolve_api_url("https://git.example.test/~api/users/me", conn),
    "https://git.example.test/~api/users/me"
  )
  expect_equal(
    .od_resolve_api_url("HTTPS://GIT.example.test/~api/x", conn),
    "HTTPS://GIT.example.test/~api/x"
  )
})

test_that("absolute URLs on another host or scheme are refused", {
  expect_error(.od_resolve_api_url("https://evil.example.test/steal", conn), "refusing")
  expect_error(.od_resolve_api_url("http://git.example.test/~api/x", conn), "refusing")
  expect_error(.od_resolve_api_url("https://git.example.test.evil.test/x", conn), "refusing")
  expect_error(.od_resolve_api_url("https://git.example.test:8443/x", conn), "refusing")
})

test_that("absolute URLs are refused when no host is configured", {
  expect_error(.od_resolve_api_url("https://git.example.test/x", list()), "refusing")
})

test_that("relative endpoints are joined to the API base", {
  expect_equal(
    .od_resolve_api_url("/issues", conn),
    "https://git.example.test/~api/issues"
  )
})
