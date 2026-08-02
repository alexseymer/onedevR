test_that(".od_artifact_path encodes segments", {
  expect_equal(onedevr:::.od_artifact_path(NULL), "")
  expect_equal(onedevr:::.od_artifact_path("/reports/a b.txt", leading_slash = TRUE), "/reports/a%20b.txt")
  expect_equal(onedevr:::.od_artifact_path("reports/out.txt"), "reports/out.txt")
})

test_that("od_list_build_artifacts hits infos endpoint", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_build_artifacts, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/artifacts/501/infos/reports")
    list(list(name = "out.txt", directory = FALSE))
  })
  out <- od_list_build_artifacts(
    501,
    artifact_path = "reports",
    use_internal_id = TRUE,
    conn = list()
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(out$name, "out.txt")
})

test_that("od_download_build_artifact writes file bytes", {
  skip_if_not_installed("mockery")
  mockery::stub(od_download_build_artifact, ".od_request_raw", function(method, endpoint, ...) {
    expect_equal(endpoint, "/artifacts/501/contents/reports/out.txt")
    charToRaw("hello-artifact")
  })
  tmp <- withr::local_tempfile(fileext = ".txt")
  path <- od_download_build_artifact(
    501,
    "reports/out.txt",
    tmp,
    use_internal_id = TRUE,
    conn = list()
  )
  expect_equal(readChar(path, 100), "hello-artifact")
})

test_that(".od_resolve_markdown_url joins relative paths", {
  expect_equal(
    onedevr:::.od_resolve_markdown_url("https://git.example.test", "/~downloads/x.png"),
    "https://git.example.test/~downloads/x.png"
  )
  expect_equal(
    onedevr:::.od_resolve_markdown_url("https://git.example.test", "https://cdn.example/a.png"),
    "https://cdn.example/a.png"
  )
})

test_that("od_download writes authenticated body", {
  skip_if_not_installed("mockery")
  mockery::stub(od_download, ".od_request_raw", function(method, endpoint, ...) {
    expect_equal(endpoint, "https://git.example.test/~downloads/x.png")
    charToRaw("img")
  })
  tmp <- withr::local_tempfile(fileext = ".png")
  path <- od_download(
    "/~downloads/x.png",
    tmp,
    conn = list(host = "https://git.example.test", token = "t")
  )
  expect_equal(readChar(path, 10), "img")
})
