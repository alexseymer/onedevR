test_that("od_get_config reads ONEDEV env vars and derives project path", {
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test/",
    ONEDEV_API_TOKEN = "api-token",
    ONEDEV_USERNAME = "",
    ONEDEV_PASSWORD = "",
    ONEDEV_AUTH = "",
    ONEDEV_REPO_URL = "https://git.example.test/group/subgroup/project.git",
    ONEDEV_PROJECT_ID = "20",
    ONEDEV_PROJECT_PATH = "",
    ONEDEV_ISSUE_STATE = "Open",
    ONEDEV_CURL_INSECURE = "1"
  )

  cfg <- od_get_config()

  expect_equal(cfg$host, "https://git.example.test")
  expect_equal(cfg$api_base_url, "https://git.example.test/~api")
  expect_equal(cfg$token, "api-token")
  expect_equal(cfg$auth, "bearer")
  expect_equal(cfg$project_id, "20")
  expect_equal(cfg$project_path, "group/subgroup/project")
  expect_equal(cfg$default_issue_state, "Open")
  expect_true(isTRUE(cfg$insecure_ssl))
})

test_that("od_get_config supports Basic Auth via username/password", {
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test",
    ONEDEV_API_TOKEN = "",
    ONEDEV_TOKEN = "",
    ONEDEV_ISSUE_REPORTER_API_KEY = "",
    ONEDEV_USERNAME = "alice",
    ONEDEV_PASSWORD = "secret",
    ONEDEV_AUTH = ""
  )
  cfg <- od_get_config()
  expect_equal(cfg$auth, "basic")
  expect_equal(cfg$username, "alice")
  expect_equal(cfg$password, "secret")
})

test_that("od_get_config prefers ONEDEV_PROJECT_PATH over repo URL", {
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test",
    ONEDEV_API_TOKEN = "t",
    ONEDEV_PROJECT_PATH = "explicit/path",
    ONEDEV_REPO_URL = "https://git.example.test/other/path.git"
  )
  expect_equal(od_get_config()$project_path, "explicit/path")
})

test_that("od_get_config token fallbacks work", {
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test",
    ONEDEV_API_TOKEN = "",
    ONEDEV_TOKEN = "",
    ONEDEV_ISSUE_REPORTER_API_KEY = "legacy-key"
  )
  expect_equal(od_get_config()$token, "legacy-key")
})

test_that("od_get_config errors when host/token missing", {
  withr::local_envvar(
    ONEDEV_HOST = "",
    ONEDEV_API_TOKEN = "",
    ONEDEV_TOKEN = "",
    ONEDEV_ISSUE_REPORTER_API_KEY = "",
    ONEDEV_USERNAME = "",
    ONEDEV_PASSWORD = "",
    ONEDEV_AUTH = ""
  )
  expect_error(od_get_config(), "ONEDEV_HOST is missing")

  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test",
    ONEDEV_API_TOKEN = "",
    ONEDEV_TOKEN = "",
    ONEDEV_ISSUE_REPORTER_API_KEY = "",
    ONEDEV_USERNAME = "",
    ONEDEV_PASSWORD = "",
    ONEDEV_AUTH = ""
  )
  expect_error(od_get_config(), "No OneDev token found")
})

test_that("od_get_config(validate = FALSE) allows empty host/token", {
  withr::local_envvar(
    ONEDEV_HOST = "",
    ONEDEV_API_TOKEN = "",
    ONEDEV_TOKEN = "",
    ONEDEV_ISSUE_REPORTER_API_KEY = ""
  )
  cfg <- od_get_config(validate = FALSE)
  expect_equal(cfg$host, "")
  expect_equal(cfg$token, "")
})
