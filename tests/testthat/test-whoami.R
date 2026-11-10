test_that("od_whoami returns the login name from /users/me", {
  skip_if_not_installed("mockery")
  mockery::stub(od_whoami, "od_get_me", function(...) list(id = 7, name = "alice"))
  expect_equal(od_whoami(conn = list(username = "other")), "alice")
})

test_that("od_whoami falls back to the configured username on HTTP 403", {
  skip_if_not_installed("mockery")
  mockery::stub(od_whoami, "od_get_me", function(...) {
    stop("OneDev API request failed [HTTP 403]: Forbidden", call. = FALSE)
  })
  expect_equal(od_whoami(conn = list(username = "alex")), "alex")
})

test_that("od_whoami falls back on HTTP 401 and 404 as well", {
  skip_if_not_installed("mockery")
  for (code in c(401L, 404L)) {
    mockery::stub(od_whoami, "od_get_me", function(...) {
      stop(sprintf("OneDev API request failed [HTTP %d]", code), call. = FALSE)
    })
    expect_equal(od_whoami(conn = list(username = "alex")), "alex")
  }
})

test_that("od_whoami explains what to set when nothing is available", {
  skip_if_not_installed("mockery")
  mockery::stub(od_whoami, "od_get_me", function(...) {
    stop("OneDev API request failed [HTTP 403]: Forbidden", call. = FALSE)
  })
  expect_error(od_whoami(conn = list()), "HTTP 403.*no username is configured.*ONEDEV_USERNAME.*ONEDEV_AUTH=bearer")
})

test_that("od_whoami does not hide other errors", {
  skip_if_not_installed("mockery")
  mockery::stub(od_whoami, "od_get_me", function(...) {
    stop("OneDev API request failed [HTTP 500]: Server Error", call. = FALSE)
  })
  expect_error(od_whoami(conn = list(username = "alex")), "HTTP 500")
})

test_that("user-id helpers resolve the configured name when /users/me is refused", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_user_emails, "od_get_me", function(...) {
    stop("OneDev API request failed [HTTP 403]", call. = FALSE)
  })
  mockery::stub(od_get_user_emails, "od_whoami", function(...) "alex")
  mockery::stub(od_get_user_emails, "od_resolve_user_id", function(user, ...) {
    expect_equal(user, "alex")
    "42"
  })
  mockery::stub(od_get_user_emails, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/users/42/email-addresses")
    list()
  })
  expect_equal(nrow(od_get_user_emails(conn = list())), 0)
})

test_that("an explicit bearer auth keeps token auth when a username is set", {
  conn <- od_connection(
    host = "https://git.example.test",
    token = "t",
    username = "alex",
    auth = "bearer"
  )
  expect_equal(conn$auth, "bearer")
  expect_equal(conn$username, "alex")
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test",
    ONEDEV_API_TOKEN = "t",
    ONEDEV_USERNAME = "alex",
    ONEDEV_AUTH = "bearer",
    ONEDEV_PASSWORD = ""
  )
  cfg <- od_get_config()
  expect_equal(cfg$auth, "bearer")
  expect_equal(cfg$username, "alex")
})
