test_that("od_resolve_issue_id uses UI number query with project path", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_issue_id, "od_resolve_project_path", function(conn = NULL) {
    "my-project"
  })
  mockery::stub(od_resolve_issue_id, "od_query_issues", function(query, count, offset, conn = NULL) {
    expect_equal(query, '"Number" is "my-project#145"')
    expect_equal(count, 1L)
    list(list(id = 283, number = 145))
  })

  issue_id <- od_resolve_issue_id("#145", conn = list(host = "https://git.example.test"))
  expect_equal(issue_id, "283")
})

test_that("od_resolve_issue_id errors when issue not found", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_issue_id, "od_resolve_project_path", function(conn = NULL) "my-project")
  mockery::stub(od_resolve_issue_id, "od_query_issues", function(...) list())
  expect_error(
    od_resolve_issue_id("#999", conn = list()),
    "#999 was not found"
  )
})

test_that("od_resolve_project_path uses conn fields", {
  expect_equal(
    od_resolve_project_path(conn = list(project_path = "group/proj")),
    "group/proj"
  )
  expect_equal(
    od_resolve_project_path(conn = list(
      project_path = "",
      repo_url = "https://git.example.test/a/b.git"
    )),
    "a/b"
  )
  expect_error(
    od_resolve_project_path(conn = list(project_path = "", repo_url = "")),
    "No project path"
  )
})

test_that("od_resolve_project_id returns cached project_id without network", {
  id <- od_resolve_project_id(conn = list(project_id = "42", project_path = "x"))
  expect_equal(id, "42")
})

test_that("od_resolve_project_id treats numeric project as id", {
  expect_equal(
    od_resolve_project_id(project = "99", conn = list(project_id = "")),
    "99"
  )
})
