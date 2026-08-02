test_that("od_query_projects hits /projects with paging", {
  skip_if_not_installed("mockery")

  mockery::stub(od_query_projects, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/projects")
    expect_equal(query$count, 10L)
    expect_equal(query$offset, 5L)
    expect_equal(query$query, '"Name" is "demo"')
    list(list(id = 1, path = "group/demo"))
  })

  out <- od_query_projects(
    query = '"Name" is "demo"',
    count = 10L,
    offset = 5L,
    conn = list()
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(out$path, "group/demo")

  mockery::stub(od_list_projects, "od_query_projects", function(...) {
    list(list(id = 2, path = "via-alias"))
  })
  aliased <- od_list_projects(conn = list(), as_tibble = FALSE)
  expect_equal(aliased[[1]]$path, "via-alias")
})

test_that("od_get_project and clone-url resolve project id", {
  skip_if_not_installed("mockery")

  mockery::stub(od_get_project, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_project, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/projects/20")
    list(id = 20, path = "group/p")
  })
  expect_equal(od_get_project(conn = list())$path, "group/p")

  mockery::stub(od_get_project_clone_url, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_project_clone_url, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/projects/20/clone-url")
    list(httpUrl = "https://git.example.test/group/p")
  })
  expect_equal(
    od_get_project_clone_url(conn = list())$httpUrl,
    "https://git.example.test/group/p"
  )
})
