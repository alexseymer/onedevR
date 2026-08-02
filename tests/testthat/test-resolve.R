test_that(".od_number_query_variants prefers path then bare forms", {
  variants <- onedevr:::.od_number_query_variants("group/proj", "#145")
  expect_equal(
    variants,
    c(
      '"Number" is "group/proj#145"',
      '"Number" is "#145"',
      '"Number" is "145"'
    )
  )
})

test_that("od_resolve_issue_id tries path then bare Number queries", {
  skip_if_not_installed("mockery")

  seen <- character()
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_issues = function(query, count, offset, conn = NULL) {
      seen <<- c(seen, query)
      if (grepl("my-project#", query, fixed = TRUE)) {
        stop("Invalid number: my-project#145", call. = FALSE)
      }
      expect_equal(count, 1L)
      list(list(id = 283, number = 145))
    },
    {
      issue_id <- od_resolve_issue_id("#145", conn = list(host = "https://git.example.test"))
      expect_equal(issue_id, "283")
    },
    .package = "onedevr"
  )
  expect_equal(seen[[1]], '"Number" is "my-project#145"')
  expect_true(any(grepl('"Number" is "#145"', seen, fixed = TRUE)))
})

test_that("od_resolve_issue_id errors when issue not found", {
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_issues = function(...) list(),
    {
      expect_error(od_resolve_issue_id("#999", conn = list()), "#999 was not found")
    },
    .package = "onedevr"
  )
})

test_that("od_resolve_build_id falls back to bare Number query", {
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_builds = function(query, count, offset, conn = NULL) {
      if (grepl("my-project#", query, fixed = TRUE)) {
        stop("Invalid number", call. = FALSE)
      }
      list(list(id = 501, number = 100))
    },
    {
      expect_equal(od_resolve_build_id("#100", conn = list()), "501")
    },
    .package = "onedevr"
  )
})

test_that("od_resolve_build_id errors when build not found", {
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_builds = function(...) list(),
    {
      expect_error(od_resolve_build_id("#999", conn = list()), "build #999 was not found")
    },
    .package = "onedevr"
  )
})

test_that("od_resolve_pull_request_id falls back to bare Number query", {
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_pull_requests = function(query, count, offset, conn = NULL) {
      if (grepl("my-project#", query, fixed = TRUE)) {
        stop("Invalid number", call. = FALSE)
      }
      list(list(id = 900, number = 42))
    },
    {
      expect_equal(od_resolve_pull_request_id("#42", conn = list()), "900")
    },
    .package = "onedevr"
  )
})

test_that("od_resolve_pull_request_id errors when PR not found", {
  with_mocked_bindings(
    od_resolve_project_path = function(conn = NULL) "my-project",
    od_query_pull_requests = function(...) list(),
    {
      expect_error(
        od_resolve_pull_request_id("#999", conn = list()),
        "pull request #999 was not found"
      )
    },
    .package = "onedevr"
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
