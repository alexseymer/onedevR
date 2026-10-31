# Coverage for exports that no other test file references by name, plus a
# guard so that every new export gets at least one test reference.

test_that("od_get_commit GETs /repositories/{id}/commits/{hash}", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_commit, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_commit, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/repositories/20/commits/abc123")
    expect_true(length(query) > 0)
    list(commitHash = "abc123")
  })
  expect_equal(od_get_commit("abc123", conn = list())$commitHash, "abc123")
})

test_that("od_get_commit rejects an empty hash", {
  expect_error(od_get_commit("", conn = list()), "commit_hash")
})

test_that("od_get_default_branch returns the branch name or NULL", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_default_branch, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_default_branch, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/default-branch")
    "main"
  })
  expect_equal(od_get_default_branch(conn = list()), "main")

  mockery::stub(od_get_default_branch, "od_request", function(...) NULL)
  expect_null(od_get_default_branch(conn = list()))
})

test_that("od_get_pack_blobs and od_get_pack_labels hit package sub-resources", {
  skip_if_not_installed("mockery")

  mockery::stub(od_get_pack_blobs, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/packages/9/blobs")
    list(list(name = "a.tar.gz"))
  })
  blobs <- od_get_pack_blobs(9, conn = list())
  expect_s3_class(blobs, "tbl_df")
  expect_equal(blobs$name, "a.tar.gz")

  mockery::stub(od_get_pack_labels, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/packages/9/labels")
    list(list(name = "latest"))
  })
  labels <- od_get_pack_labels(9, as_tibble = FALSE, conn = list())
  expect_type(labels, "list")
  expect_equal(labels[[1]]$name, "latest")
})

test_that("od_get_pack_blobs and od_get_pack_labels require a package id", {
  expect_error(od_get_pack_blobs("", conn = list()), "pack_id")
  expect_error(od_get_pack_labels("", conn = list()), "pack_id")
})

test_that("od_get_tag URL-encodes the tag name", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_tag, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_tag, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/tags/v1.0%2B1")
    list(refName = "v1.0+1", commitHash = "def456")
  })
  expect_equal(od_get_tag("v1.0+1", conn = list())$commitHash, "def456")
})

test_that("od_list_tags returns tag names as a character vector", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_tags, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_list_tags, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/repositories/20/tags")
    list("v1.0.0", "v2.0.0")
  })
  tags <- od_list_tags(conn = list())
  expect_type(tags, "character")
  expect_equal(tags, c("v1.0.0", "v2.0.0"))
})

test_that("od_get_user_emails uses the current user when no user is given", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_user_emails, "od_get_me", function(...) list(id = 7))
  mockery::stub(od_get_user_emails, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/users/7/email-addresses")
    list(list(value = "alice@example.test"))
  })
  emails <- od_get_user_emails(conn = list())
  expect_s3_class(emails, "tbl_df")
  expect_equal(emails$value, "alice@example.test")
})

test_that("od_get_user_emails resolves a named user", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_user_emails, "od_resolve_user_id", function(...) "42")
  mockery::stub(od_get_user_emails, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/users/42/email-addresses")
    list()
  })
  expect_equal(nrow(od_get_user_emails("bob", conn = list())), 0)
})

test_that("every exported function is referenced by at least one test", {
  exports <- getNamespaceExports("onedevr")
  files <- list.files(testthat::test_path(), pattern = "\\.R$", full.names = TRUE)
  text <- paste(
    vapply(files, function(f) paste(readLines(f, warn = FALSE), collapse = "\n"), character(1)),
    collapse = "\n"
  )
  is_referenced <- vapply(
    exports,
    function(e) grepl(paste0("\\b", e, "\\b"), text),
    logical(1)
  )
  expect_equal(unname(exports[!is_referenced]), character(0))
})

test_that("od_get_file_text decodes base64 file content", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_file_text, "od_get_file", function(...) {
    list(base64Content = jsonlite::base64_enc(charToRaw("hello\n")))
  })
  expect_equal(od_get_file_text("main", "README.md", conn = list()), "hello\n")
})

test_that("od_get_file_text returns an empty string when content is missing", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_file_text, "od_get_file", function(...) list())
  expect_equal(od_get_file_text("main", "empty.txt", conn = list()), "")
})

test_that("od_parallel_query runs queries through future and reports errors per item", {
  skip_if_not_installed("future")
  withr::local_options(future.globals.maxSize = Inf)
  future::plan(future::sequential)
  withr::defer(future::plan(future::sequential))

  result <- od_parallel_query(
    queries = list(list(fn = "od_no_such_function")),
    conn = list()
  )
  expect_length(result, 1)
  expect_true(isTRUE(result[[1]]$error))
  expect_match(result[[1]]$message, "od_no_such_function")
})
