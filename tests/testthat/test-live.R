test_that("od_get_issue live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  issue_number <- issues[[1]]$number
  issue <- od_get_issue(issue_number)
  expect_true(!is.null(issue$title))
  expect_equal(as.character(issue$number), as.character(issue_number))
})

test_that("od_list_iterations live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  iterations <- od_list_iterations()
  expect_s3_class(iterations, "tbl_df")
})

test_that("od_get_issue_fields live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  fields <- od_get_issue_fields(issues[[1]]$number)
  expect_true(is.list(fields))
})

test_that("od_query_builds live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 5L)
  expect_s3_class(builds, "tbl_df")
})

test_that("od_query_pull_requests live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- od_query_pull_requests(count = 5L)
  expect_s3_class(pulls, "tbl_df")
})

test_that("od_get_build live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  build <- od_get_build(builds[[1]]$number)
  expect_equal(as.character(build$number), as.character(builds[[1]]$number))
})

test_that("od_get_pull_request live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- od_query_pull_requests(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(pulls) < 1L, "No pull requests available in project")
  pr <- od_get_pull_request(pulls[[1]]$number)
  expect_equal(as.character(pr$number), as.character(pulls[[1]]$number))
})

test_that("od_get_issue_comments live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  comments <- od_get_issue_comments(issues[[1]]$number)
  expect_s3_class(comments, "tbl_df")
})

test_that("od_get_build_params and log live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  params <- od_get_build_params(builds[[1]]$number)
  expect_true(is.list(params))
  lines <- od_get_build_log(builds[[1]]$number)
  expect_true(is.character(lines))
  expect_true(length(lines) >= 1L)
})

test_that("od_query_projects and od_get_project live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  projects <- od_query_projects(count = 5L)
  expect_s3_class(projects, "tbl_df")
  expect_true(nrow(projects) >= 1L)

  project <- od_get_project()
  expect_true(!is.null(project$id) || !is.null(project$path))

  me <- tryCatch(od_get_me(), error = function(e) NULL)
  skip_if(is.null(me), "/users/me not authorized for this token")
  expect_true(!is.null(me$name) || !is.null(me$id))
})

test_that("od_list_build_artifacts live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  artifacts <- tryCatch(
    od_list_build_artifacts(builds[[1]]$number),
    error = function(e) NULL
  )
  skip_if(is.null(artifacts), "Artifact listing failed or unavailable")
  expect_true(inherits(artifacts, "tbl_df") || is.list(artifacts))
})

test_that("repository branches and commits live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  branches <- tryCatch(od_list_branches(), error = function(e) NULL)
  skip_if(is.null(branches) || !length(branches), "No branches / no code read permission")
  expect_true(is.character(branches))

  tip <- od_get_branch(branches[[1]])
  expect_true(nzchar(tip$commitHash %||% ""))

  commits <- od_query_commits(count = 3L)
  expect_s3_class(commits, "tbl_df")
})

test_that("build status keyword and file text live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(status = "successful", count = 3L)
  expect_s3_class(builds, "tbl_df")

  pulls <- od_query_pull_requests(status = "open", count = 5L)
  expect_s3_class(pulls, "tbl_df")

  desc <- tryCatch(od_get_query_description("build"), error = function(e) NULL)
  skip_if(is.null(desc), "query description endpoint unavailable")
  expect_true(grepl("successful|buildQuery", desc))

  txt <- tryCatch(od_get_file_text("main", "README.md"), error = function(e) NULL)
  skip_if(is.null(txt), "README.md missing on default branch")
  expect_true(nzchar(txt))
})
