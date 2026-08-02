test_that("branch/tag/commit helpers hit repository endpoints", {
  skip_if_not_installed("mockery")

  mockery::stub(od_list_branches, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_list_branches, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/branches")
    list("main", "dev")
  })
  expect_equal(od_list_branches(conn = list()), c("main", "dev"))

  mockery::stub(od_get_branch, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_branch, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/branches/main")
    list(refName = "refs/heads/main", commitHash = "abc")
  })
  expect_equal(od_get_branch("main", conn = list())$commitHash, "abc")

  mockery::stub(od_query_commits, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_query_commits, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(endpoint, "/repositories/20/commits")
    expect_equal(query$count, 5L)
    expect_true("AUTHOR" %in% query$field)
    list(list(commitHash = "abc", subject = "hi"))
  })
  commits <- od_query_commits(count = 5L, conn = list())
  expect_s3_class(commits, "tbl_df")

  mockery::stub(od_get_file, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_file, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/files/main/R/utils.R")
    list(path = "R/utils.R")
  })
  expect_equal(od_get_file("main", "R/utils.R", conn = list())$path, "R/utils.R")
})

test_that(".od_repo_path_encode encodes each segment", {
  expect_equal(
    onedevr:::.od_repo_path_encode(c("main", "R", "a b.R")),
    "main/R/a%20b.R"
  )
})
