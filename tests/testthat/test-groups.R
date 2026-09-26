test_that("od_query_groups hits /groups with pagination", {
  skip_if_not_installed("mockery")
  mockery::stub(od_query_groups, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/groups")
    expect_equal(query$count, 10L)
    expect_equal(query$offset, 5L)
    list(list(name = "developers", id = 1))
  })
  groups <- od_query_groups(count = 10L, offset = 5L, conn = list())
  expect_s3_class(groups, "tbl_df")
  expect_equal(groups$name, "developers")
})

test_that("od_get_group retrieves a group by name", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_group, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/groups/developers")
    list(name = "developers", id = 1)
  })
  group <- od_get_group("developers", conn = list())
  expect_equal(group$name, "developers")
})

test_that("od_list_group_members retrieves members", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_group_members, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/groups/developers/members")
    list(list(name = "alice", id = 1), list(name = "bob", id = 2))
  })
  members <- od_list_group_members("developers", conn = list())
  expect_equal(nrow(members), 2)
  expect_equal(members$name[[1]], "alice")
})

test_that("od_add_group_member sends POST with user id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_group_member, "od_resolve_user_id", function(...) "7")
  mockery::stub(od_add_group_member, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/groups/developers/members")
    expect_equal(body$userId, 7L)
    list(ok = TRUE)
  })
  result <- od_add_group_member("developers", "alice", conn = list())
  expect_equal(result$ok, TRUE)
})

test_that("od_remove_group_member sends DELETE", {
  skip_if_not_installed("mockery")
  mockery::stub(od_remove_group_member, "od_resolve_user_id", function(...) "7")
  mockery::stub(od_remove_group_member, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "DELETE")
    expect_equal(endpoint, "/groups/developers/members/7")
    NULL
  })
  result <- od_remove_group_member("developers", "alice", conn = list())
  expect_null(result)
})
