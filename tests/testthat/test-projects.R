test_that("od_query_projects hits /projects with paging", {
  skip_if_not_installed("mockery")

  mockery::stub(od_query_projects, "od_request", function(method, endpoint, query = NULL, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/projects")
    expect_equal(query$count, 10L)
    expect_equal(query$offset, 5L)
    expect_equal(query$query, '"Name" is "demo"')
    list(list(id = 1, path = "group/demo"))
  })

  out <- od_query_projects(
    query = '"Name" is "demo"',
    count = 10L,
    offset = 5L,
    conn = list()
  )
  expect_s3_class(out, "tbl_df")
  expect_equal(out$path, "group/demo")

  mockery::stub(od_list_projects, "od_query_projects", function(...) {
    list(list(id = 2, path = "via-alias"))
  })
  aliased <- od_list_projects(conn = list(), as_tibble = FALSE)
  expect_equal(aliased[[1]]$path, "via-alias")
})

test_that("od_get_project and clone-url resolve project id", {
  skip_if_not_installed("mockery")

  mockery::stub(od_get_project, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_project, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/projects/20")
    list(id = 20, path = "group/p")
  })
  expect_equal(od_get_project(conn = list())$path, "group/p")

  mockery::stub(od_get_project_clone_url, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_project_clone_url, "od_request", function(method, endpoint, ...) {
    expect_equal(endpoint, "/projects/20/clone-url")
    list(httpUrl = "https://git.example.test/group/p")
  })
  expect_equal(
    od_get_project_clone_url(conn = list())$httpUrl,
    "https://git.example.test/group/p"
  )
})

test_that("od_list_webhooks retrieves project webhooks", {
  skip_if_not_installed("mockery")
  mockery::stub(od_list_webhooks, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_list_webhooks, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/projects/20/webhooks")
    list(
      list(id = 1, url = "https://example.com/webhook1"),
      list(id = 2, url = "https://example.com/webhook2")
    )
  })
  webhooks <- od_list_webhooks(conn = list())
  expect_equal(nrow(webhooks), 2)
  expect_equal(webhooks$url[[1]], "https://example.com/webhook1")
})

test_that("od_get_webhook retrieves a specific webhook", {
  skip_if_not_installed("mockery")
  mockery::stub(od_get_webhook, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_get_webhook, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/projects/20/webhooks/1")
    list(id = 1, url = "https://example.com/webhook", events = c("push", "pull_request"))
  })
  webhook <- od_get_webhook(1, conn = list())
  expect_equal(webhook$url, "https://example.com/webhook")
})

test_that("od_create_webhook sends URL and optional events", {
  skip_if_not_installed("mockery")
  mockery::stub(od_create_webhook, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_create_webhook, "od_request", function(method, endpoint, body = NULL, ...) {
    expect_equal(method, "POST")
    expect_equal(endpoint, "/projects/20/webhooks")
    expect_equal(body$url, "https://example.com/webhook")
    expect_equal(body$events, c("push", "pull_request"))
    list(id = 1, url = "https://example.com/webhook")
  })
  webhook <- od_create_webhook(
    "https://example.com/webhook",
    events = c("push", "pull_request"),
    conn = list()
  )
  expect_equal(webhook$id, 1)
})

test_that("od_delete_webhook sends DELETE request", {
  skip_if_not_installed("mockery")
  mockery::stub(od_delete_webhook, "od_resolve_project_id", function(...) "20")
  mockery::stub(od_delete_webhook, "od_request", function(method, endpoint, ...) {
    expect_equal(method, "DELETE")
    expect_equal(endpoint, "/projects/20/webhooks/1")
    NULL
  })
  result <- od_delete_webhook(1, conn = list())
  expect_null(result)
})
