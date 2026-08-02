test_that("od_get_issue live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- onedevr:::.od_normalize_collection(od_query_issues(count = 1L, offset = 0L))
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
  expect_true(is.list(iterations))
})

test_that("od_get_issue_fields live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- onedevr:::.od_normalize_collection(od_query_issues(count = 1L, offset = 0L))
  skip_if(length(issues) < 1L, "No issues available in project")
  fields <- od_get_issue_fields(issues[[1]]$number)
  expect_true(is.list(fields))
})

test_that("od_query_builds live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 5L)
  expect_true(is.list(builds))
})

test_that("od_query_pull_requests live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- od_query_pull_requests(count = 5L)
  expect_true(is.list(pulls))
})

test_that("od_get_build live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- onedevr:::.od_normalize_collection(od_query_builds(count = 1L, offset = 0L))
  skip_if(length(builds) < 1L, "No builds available in project")
  build <- od_get_build(builds[[1]]$number)
  expect_equal(as.character(build$number), as.character(builds[[1]]$number))
})

test_that("od_get_pull_request live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- onedevr:::.od_normalize_collection(od_query_pull_requests(count = 1L, offset = 0L))
  skip_if(length(pulls) < 1L, "No pull requests available in project")
  pr <- od_get_pull_request(pulls[[1]]$number)
  expect_equal(as.character(pr$number), as.character(pulls[[1]]$number))
})
