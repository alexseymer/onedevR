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
  expect_equal(captured$query$query, "successful")
  expect_equal(captured$query$count, 10L)

  od_query_builds(query = '"Job" is "CI"', status = "FAILED", conn = list())
  expect_equal(captured$query$query, '("Job" is "CI") and failed')

  expect_error(od_query_builds(status = "nope", conn = list()), "Unknown build status")
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

test_that("od_get_build_params GETs params endpoint", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_build_params, "od_resolve_build_id", function(...) "501")
  mockery::stub(od_get_build_params, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/builds/501/params")
    list(FOO = "bar")
  })
  expect_equal(od_get_build_params(100, conn = list())$FOO, "bar")
})

test_that(".od_parse_build_log_raw extracts status and message text", {
  status <- charToRaw("SUCCESSFUL")
  json <- charToRaw('{"date":"t","messages":[{"text":"hello"}]}')
  pack_i32be <- function(n) {
    writeBin(as.integer(n), raw(), size = 4L, endian = "big")
  }
  raw <- c(pack_i32be(-10L), status, pack_i32be(length(json)), json)
  lines <- onedevr:::.od_parse_build_log_raw(raw)
  expect_equal(lines[[1]], "[status] SUCCESSFUL")
  expect_equal(lines[[2]], "hello")
})

test_that("od_get_build_log uses streaming endpoint", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_build_log, "od_resolve_build_id", function(...) "501")
  mockery::stub(od_get_build_log, ".od_request_raw", function(method, endpoint, ...) {
    expect_equal(endpoint, "/streaming/build-logs/501")
    raw(0)
  })
  mockery::stub(od_get_build_log, ".od_parse_build_log_raw", function(raw) c("line1"))
  expect_equal(od_get_build_log(100, conn = list()), "line1")
})
