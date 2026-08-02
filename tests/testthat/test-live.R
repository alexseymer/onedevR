test_that("od_get_issue live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issue <- od_get_issue(1)
  expect_true(!is.null(issue$title))
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

  fields <- od_get_issue_fields(1)
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
