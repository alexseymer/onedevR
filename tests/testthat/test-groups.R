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

test_that(".od_resolve_group_id looks a name up and takes numbers as ids", {
  seen <- NULL
  fake <- function(method, endpoint, conn = NULL) {
    seen <<- c(seen, paste(method, endpoint))
    7L
  }
  expect_equal(.od_resolve_group_id("developers", request = fake), 7L)
  expect_equal(seen, "GET /groups/ids/developers")
  expect_equal(.od_resolve_group_id("my group/x", request = fake), 7L)
  expect_equal(seen[[2]], "GET /groups/ids/my%20group%2Fx")
  expect_equal(.od_resolve_group_id(12, request = fake), 12L)
  expect_equal(.od_resolve_group_id("12", request = fake), 12L)
  expect_length(seen, 2L)  # numbers need no lookup
  expect_error(.od_resolve_group_id("", request = fake), "group")
})

test_that("od_get_group resolves the name, then GETs the group by id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_group, ".od_resolve_group_id", function(...) 5L)
  mockery::stub(od_get_group, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/groups/5")
    list(id = 5, name = "developers", description = "d", administrator = FALSE)
  })
  group <- od_get_group("developers", conn = list())
  expect_equal(group$name, "developers")
})

test_that("od_list_group_members returns the memberships of the group", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_group_members, ".od_resolve_group_id", function(...) 5L)
  mockery::stub(od_list_group_members, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/groups/5/memberships")
    list(list(id = 1, userId = 3, groupId = 5), list(id = 2, userId = 4, groupId = 5))
  })
  members <- od_list_group_members("developers", conn = list())
  expect_equal(nrow(members), 2)
  expect_equal(members$userId, c(3, 4))
  expect_named(members, c("id", "userId", "groupId"))
})

test_that("od_add_group_member POSTs a membership with userId and groupId", {
  skip_if_not_installed("mockery")
  mockery::stub(od_add_group_member, ".od_resolve_group_id", function(...) 5L)
  mockery::stub(od_add_group_member, "od_resolve_user_id", function(...) "7")
  sent <- NULL
  mockery::stub(od_add_group_member, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/memberships")
    sent <<- body
    11L
  })
  expect_equal(od_add_group_member("developers", "alice", conn = list()), 11L)
  expect_equal(sent, list(userId = 7L, groupId = 5L))
})

test_that("od_remove_group_member deletes the membership of that user", {
  skip_if_not_installed("mockery")
  mockery::stub(od_remove_group_member, ".od_resolve_group_id", function(...) 5L)
  mockery::stub(od_remove_group_member, "od_resolve_user_id", function(...) "4")
  calls <- character()
  mockery::stub(od_remove_group_member, "od_request", function(method, endpoint, ...) {
    calls <<- c(calls, paste(method, endpoint))
    if (method == "GET") {
      list(list(id = 1, userId = 3, groupId = 5), list(id = 2, userId = 4, groupId = 5))
    } else {
      NULL
    }
  })
  expect_null(od_remove_group_member("developers", "bob", conn = list()))
  expect_equal(calls, c("GET /groups/5/memberships", "DELETE /memberships/2"))
})

test_that("od_remove_group_member fails when the user is not a member", {
  skip_if_not_installed("mockery")
  mockery::stub(od_remove_group_member, ".od_resolve_group_id", function(...) 5L)
  mockery::stub(od_remove_group_member, "od_resolve_user_id", function(...) "9")
  calls <- character()
  mockery::stub(od_remove_group_member, "od_request", function(method, endpoint, ...) {
    calls <<- c(calls, method)
    list(list(id = 1, userId = 3, groupId = 5))
  })
  expect_error(od_remove_group_member("developers", "eve", conn = list()), "not a member")
  expect_equal(calls, "GET")  # nothing is deleted
})
