test_that("od_connection builds a validated connection list", {
  conn <- od_connection(
    host = "https://git.example.test/",
    token = "tok",
    project_path = "group/project",
    project_id = 20,
    default_issue_state = "Open",
    insecure_ssl = TRUE
  )

  expect_s3_class(conn, "od_connection")
  expect_equal(conn$host, "https://git.example.test")
  expect_equal(conn$api_base_url, "https://git.example.test/~api")
  expect_equal(conn$token, "tok")
  expect_equal(conn$project_path, "group/project")
  expect_equal(conn$project_id, "20")
  expect_equal(conn$default_issue_state, "Open")
  expect_true(isTRUE(conn$insecure_ssl))
})

test_that("od_connection derives project_path from repo_url", {
  conn <- od_connection(
    host = "https://git.example.test",
    token = "tok",
    repo_url = "https://git.example.test/a/b.git"
  )
  expect_equal(conn$project_path, "a/b")
})

test_that("od_connection validates host and token", {
  expect_error(od_connection(host = "", token = "t"), "`host` is missing")
  expect_error(od_connection(host = "https://x", token = ""), "`token` is missing")
})

test_that("od_set_connection / od_get_connection manage package default", {
  withr::defer(od_set_connection(NULL))
  expect_null(od_get_connection())

  conn <- od_connection(
    host = "https://git.example.test",
    token = "tok",
    project_path = "p"
  )
  od_set_connection(conn)
  expect_identical(od_get_connection(), conn)

  od_set_connection(NULL)
  expect_null(od_get_connection())
})

test_that(".od_conn prefers explicit, then default, then env", {
  withr::defer(od_set_connection(NULL))
  withr::local_envvar(
    ONEDEV_HOST = "https://env.example.test",
    ONEDEV_API_TOKEN = "env-tok",
    ONEDEV_PROJECT_PATH = "env/path"
  )

  explicit <- list(host = "https://explicit.test", token = "x")
  expect_identical(onedevr:::.od_conn(explicit), explicit)

  default <- od_connection(
    host = "https://default.example.test",
    token = "def",
    project_path = "d"
  )
  od_set_connection(default)
  expect_identical(onedevr:::.od_conn(NULL), default)

  od_set_connection(NULL)
  env_conn <- onedevr:::.od_conn(NULL)
  expect_equal(env_conn$host, "https://env.example.test")
  expect_equal(env_conn$token, "env-tok")
})
