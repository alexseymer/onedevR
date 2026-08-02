test_that(".od_job_params normalizes named values", {
  expect_equal(
    onedevr:::.od_job_params(list(A = "1", B = c("x", "y"))),
    list(A = "1", B = c("x", "y"))
  )
  expect_error(onedevr:::.od_job_params(list(1)), "named list")
})

test_that("od_run_job posts JobRunOnCommit for branch", {
  skip_if_not_installed("mockery")

  mockery::stub(od_run_job, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_run_job, "od_get_branch", function(branch, ...) {
    expect_equal(branch, "main")
    list(refName = "refs/heads/main", commitHash = "abc123")
  })
  mockery::stub(od_run_job, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/job-runs")
    expect_equal(body[["@type"]], "JobRunOnCommit")
    expect_equal(body$projectId, 20L)
    expect_equal(body$commitHash, "abc123")
    expect_equal(body$refName, "refs/heads/main")
    expect_equal(body$jobName, "CI")
    expect_equal(body$params$ENV, "prod")
    501
  })

  id <- od_run_job(
    "CI",
    branch = "main",
    params = list(ENV = "prod"),
    conn = list()
  )
  expect_equal(id, 501)
})

test_that("od_run_job posts JobRunOnPullRequest", {
  skip_if_not_installed("mockery")
  mockery::stub(od_run_job, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(body[["@type"]], "JobRunOnPullRequest")
    expect_equal(body$pullRequestId, 900L)
    expect_equal(body$jobName, "CI")
    77
  })
  expect_equal(od_run_job("CI", pull_request_id = 900, conn = list()), 77)
})

test_that("od_rebuild_job and od_cancel_job hit job-runs endpoints", {
  skip_if_not_installed("mockery")

  mockery::stub(od_rebuild_job, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/job-runs/rebuild")
    expect_equal(body$buildId, 501L)
    NULL
  })
  expect_null(od_rebuild_job(501, use_internal_id = TRUE, conn = list()))

  mockery::stub(od_cancel_job, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "DELETE")
    expect_equal(endpoint, "/job-runs/501")
    NULL
  })
  expect_null(od_cancel_job(501, use_internal_id = TRUE, conn = list()))
})
