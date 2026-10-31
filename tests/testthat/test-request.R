
test_that("insecure TLS warns once per session", {
  conn <- list(host = "https://git.example.test", auth = "bearer", token = "t", insecure_ssl = TRUE)
  .onedevr_env$insecure_warned <- FALSE
  withr::defer(.onedevr_env$insecure_warned <- FALSE)
  expect_warning(.od_prepare_request("GET", "https://git.example.test/~api/x", conn), "TLS certificate verification is disabled")
  expect_no_warning(.od_prepare_request("GET", "https://git.example.test/~api/x", conn))
})

test_that("secure connections do not warn", {
  conn <- list(host = "https://git.example.test", auth = "bearer", token = "t", insecure_ssl = FALSE)
  .onedevr_env$insecure_warned <- FALSE
  expect_no_warning(.od_prepare_request("GET", "https://git.example.test/~api/x", conn))
})
