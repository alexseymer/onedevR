test_that("od_query_builds builds status clause", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  mockery::stub(od_query_builds, "od_request", function(method, endpoint, query = NULL, body = NULL, conn = NULL) {
    captured$method <- method
    captured$endpoint <- endpoint
    captured$query <- query
    list()
  })

  od_query_builds(status = "SUCCESSFUL", count = 10L, conn = list())
  expect_equal(captured$method, "GET")
  expect_equal(captured$endpoint, "/builds")
  expect_equal(captured$query$query, 'Status is "SUCCESSFUL"')
  expect_equal(captured$query$count, 10L)

  od_query_builds(query = '"Job" is "CI"', status = "FAILED", conn = list())
  expect_equal(captured$query$query, '("Job" is "CI") and Status is "FAILED"')
})

test_that("od_get_build resolves UI number then GETs internal id", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_build, "od_resolve_build_id", function(build_number, conn = NULL) {
    expect_equal(build_number, 100)
    "501"
  })
  mockery::stub(od_get_build, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/builds/501")
    list(id = 501, number = 100, status = "SUCCESSFUL")
  })

  build <- od_get_build(100, conn = list())
  expect_equal(build$status, "SUCCESSFUL")
})
