test_that("od_resolve_user_id passes through numeric ids", {
  expect_equal(od_resolve_user_id("42", conn = list(validate = FALSE)), "42")
})

test_that("od_resolve_user_id GETs /users/ids/{name}", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_user_id, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/users/ids/alice")
    list(id = 7)
  })
  expect_equal(od_resolve_user_id("alice", conn = list()), "7")
})

test_that("od_query_users and od_get_me hit user endpoints", {
  skip_if_not_installed("mockery")

  mockery::stub(od_query_users, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(endpoint, "/users")
    expect_equal(query$count, 5L)
    list(list(id = 1, name = "alice"))
  })
  users <- od_query_users(count = 5L, conn = list())
  expect_s3_class(users, "tbl_df")
  expect_equal(users$name, "alice")

  mockery::stub(od_get_me, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/users/me")
    list(id = 1, name = "alice")
  })
  expect_equal(od_get_me(conn = list())$name, "alice")
})

test_that("od_get_user resolves login then GETs /users/{id}", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_user, "od_resolve_user_id", function(user, ...) {
    expect_equal(user, "alice")
    "7"
  })
  mockery::stub(od_get_user, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/users/7")
    list(id = 7, name = "alice")
  })
  expect_equal(od_get_user("alice", conn = list())$id, 7)
})

test_that("od_list_user_ssh_keys retrieves SSH keys", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_user_ssh_keys, "od_get_me", function(...) list(id = "1"))
  mockery::stub(od_list_user_ssh_keys, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/users/1/ssh-keys")
    list(
      list(id = 1, name = "Laptop", fingerprint = "SHA256:abc123"),
      list(id = 2, name = "Desktop", fingerprint = "SHA256:def456")
    )
  })
  keys <- od_list_user_ssh_keys(conn = list())
  expect_equal(nrow(keys), 2)
  expect_equal(keys$name[[1]], "Laptop")
})

test_that("od_add_user_ssh_key sends key content and optional name", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_user_ssh_key, "od_get_me", function(...) list(id = "1"))
  mockery::stub(od_add_user_ssh_key, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/users/1/ssh-keys")
    expect_equal(body$content, "ssh-rsa AAAA...")
    expect_equal(body$name, "Laptop")
    list(id = 1, name = "Laptop", fingerprint = "SHA256:abc123")
  })
  key <- od_add_user_ssh_key("ssh-rsa AAAA...", name = "Laptop", conn = list())
  expect_equal(key$id, 1)
})

test_that("od_delete_user_ssh_key sends DELETE request", {
  skip_if_not_installed("mockery")
  mockery::stub(od_delete_user_ssh_key, "od_get_me", function(...) list(id = "1"))
  mockery::stub(od_delete_user_ssh_key, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "DELETE")
    expect_equal(endpoint, "/users/1/ssh-keys/1")
    NULL
  })
  result <- od_delete_user_ssh_key(1, conn = list())
  expect_null(result)
})
