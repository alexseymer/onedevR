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
