test_that("od_query_packages and od_get_pack hit /packages", {
  skip_if_not_installed("mockery")

  mockery::stub(od_query_packages, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(endpoint, "/packages")
    expect_equal(query$count, 10L)
    list(list(id = 1, name = "app"))
  })
  packs <- od_query_packages(count = 10L, conn = list())
  expect_s3_class(packs, "tbl_df")
  expect_equal(packs$name, "app")

  mockery::stub(od_get_pack, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/packages/9")
    list(id = 9, name = "app")
  })
  expect_equal(od_get_pack(9, conn = list())$name, "app")
})
