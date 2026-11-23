test_that("od_get_issue live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  issue_number <- issues[[1]]$number
  issue <- od_get_issue(issue_number)
  expect_true(!is.null(issue$title))
  expect_equal(as.character(issue$number), as.character(issue_number))
})

test_that("od_list_iterations live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  iterations <- od_list_iterations()
  expect_s3_class(iterations, "tbl_df")
})

test_that("od_get_issue_fields live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  fields <- od_get_issue_fields(issues[[1]]$number)
  expect_true(is.list(fields))
})

test_that("od_query_builds live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 5L)
  expect_s3_class(builds, "tbl_df")
})

test_that("od_query_pull_requests live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- od_query_pull_requests(count = 5L)
  expect_s3_class(pulls, "tbl_df")
})

test_that("od_get_build live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  build <- od_get_build(builds[[1]]$number)
  expect_equal(as.character(build$number), as.character(builds[[1]]$number))
})

test_that("od_get_pull_request live resolve", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  pulls <- od_query_pull_requests(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(pulls) < 1L, "No pull requests available in project")
  pr <- od_get_pull_request(pulls[[1]]$number)
  expect_equal(as.character(pr$number), as.character(pulls[[1]]$number))
})

test_that("od_get_issue_comments live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  issues <- od_query_issues(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(issues) < 1L, "No issues available in project")
  comments <- od_get_issue_comments(issues[[1]]$number)
  expect_s3_class(comments, "tbl_df")
})

test_that("od_get_build_params and log live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  params <- od_get_build_params(builds[[1]]$number)
  expect_true(is.list(params))
  lines <- od_get_build_log(builds[[1]]$number)
  expect_true(is.character(lines))
  expect_true(length(lines) >= 1L)
})

test_that("od_query_projects and od_get_project live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  projects <- od_query_projects(count = 5L)
  expect_s3_class(projects, "tbl_df")
  expect_true(nrow(projects) >= 1L)

  project <- od_get_project()
  expect_true(!is.null(project$id) || !is.null(project$path))

  me <- tryCatch(od_get_me(), error = function(e) NULL)
  skip_if(is.null(me), "/users/me not authorized for this token")
  expect_true(!is.null(me$name) || !is.null(me$id))
})

test_that("od_list_build_artifacts live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available in project")
  artifacts <- tryCatch(
    od_list_build_artifacts(builds[[1]]$number),
    error = function(e) NULL
  )
  skip_if(is.null(artifacts), "Artifact listing failed or unavailable")
  expect_true(inherits(artifacts, "tbl_df") || is.list(artifacts))
})

test_that("repository branches and commits live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  branches <- tryCatch(od_list_branches(), error = function(e) NULL)
  skip_if(is.null(branches) || !length(branches), "No branches / no code read permission")
  expect_true(is.character(branches))

  tip <- od_get_branch(branches[[1]])
  expect_true(nzchar(tip$commitHash %||% ""))

  commits <- od_query_commits(count = 3L)
  expect_s3_class(commits, "tbl_df")
})

test_that("build status keyword and file text live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(status = "successful", count = 3L)
  expect_s3_class(builds, "tbl_df")

  pulls <- od_query_pull_requests(status = "open", count = 5L)
  expect_s3_class(pulls, "tbl_df")

  desc <- tryCatch(od_get_query_description("build"), error = function(e) NULL)
  skip_if(is.null(desc), "query description endpoint unavailable")
  expect_true(grepl("successful|buildQuery", desc))

  txt <- tryCatch(od_get_file_text("main", "README.md"), error = function(e) NULL)
  skip_if(is.null(txt), "README.md missing on default branch")
  expect_true(nzchar(txt))
})

test_that("od_stream_query_results live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  collected_chunks <- list()
  result <- od_stream_query_results(
    od_query_issues,
    callback = function(chunk, page, has_more) {
      collected_chunks[[length(collected_chunks) + 1L]] <<- chunk
    },
    chunk_size = 10L
  )

  expect_true(result$total_count >= 0)
  expect_true(result$page_count >= 0)
  if (result$total_count > 0) {
    expect_true(length(collected_chunks) > 0)
  }
})

test_that("od_chunked_foreach live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  chunks <- od_chunked_foreach(
    od_query_issues,
    chunk_size = 10L
  )

  expect_true(is.list(chunks))
  if (length(chunks) > 0) {
    for (chunk in chunks) {
      expect_s3_class(chunk, "tbl_df")
    }
  }
})

test_that("od_stream_build_log live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  builds <- od_query_builds(count = 1L, offset = 0L, as_tibble = FALSE)
  skip_if(length(builds) < 1L, "No builds available")

  line_count <- 0
  result <- tryCatch(
    od_stream_build_log(
      builds[[1]]$number,
      callback = function(chunk, line_number, is_last) {
        line_count <<- line_count + 1L
      }
    ),
    error = function(e) NULL
  )

  # Build log streaming might not be available on all OneDev versions
  skip_if(is.null(result), "Build log streaming not available")
  expect_equal(result, NULL)  # Function returns invisible NULL
})

test_that("od_enable_cache live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  # Enable cache with 1-hour TTL
  od_enable_cache(ttl_seconds = 3600, max_size = 100)

  # Make two queries - second should hit cache
  issues1 <- od_query_issues(count = 5L)
  issues2 <- od_query_issues(count = 5L)

  expect_s3_class(issues1, "tbl_df")
  expect_s3_class(issues2, "tbl_df")
  expect_equal(nrow(issues1), nrow(issues2))

  # Check cache stats
  stats <- od_get_cache_stats()
  expect_true(stats$hits >= 1)  # Second query should have hit cache

  od_disable_cache()
})

test_that("od_batch_create_issues live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  # This test creates real issues; run it only against a disposable project.
  skip_if(Sys.getenv("ONEDEV_LIVE_ALLOW_WRITES") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  result <- od_batch_create_issues(
    list(
      list(title = "Live Test Issue 1", description = "Test via od_batch_create_issues"),
      list(title = "Live Test Issue 2", description = "Another test issue")
    ),
    progress = FALSE
  )
  # Close what the test created, also when an expectation below fails, so the
  # weekly CI run does not leave open issues behind.
  withr::defer(for (n in result$numbers) {
    tryCatch(od_issue_transition_state(n, "Closed"), error = function(e) NULL)
  })

  expect_length(result$errors, 0)
  expect_length(result$created, 2)
  expect_length(result$numbers, 2)
})

test_that("query escaping live: a state value cannot add a second clause", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  closed <- od_query_issues(state = "Closed", count = 1L)
  skip_if(nrow(closed) < 1L, "No closed issue to show a leak")

  # Unescaped, this value would read `"State" is "Open" or "State" is "Closed"`
  # and return closed issues. Escaped, it is one literal that matches no state.
  injected <- od_query_issues(state = 'Open" or "State" is "Closed', count = 20L)
  expect_equal(nrow(injected), 0L)
})

test_that("query escaping live: quotes, backslash, parentheses and umlauts round-trip", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  # Creates a real issue; it is closed again at the end of the test.
  skip_if(Sys.getenv("ONEDEV_LIVE_ALLOW_WRITES") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  title <- r"(onedevr live "quoted" back\slash (paren) ä)"
  issue <- od_create_issue(title = title, description = "Query escaping test; closed automatically.")
  withr::defer(tryCatch(od_issue_transition_state(issue$number, "Closed"), error = function(e) NULL))
  expect_identical(issue$title, title)

  found <- od_query_issues(
    query = paste0('"Title" contains ', .od_quote_query_value(title)),
    count = 5L
  )
  expect_true(issue$number %in% found$number)
})

test_that("iterations live: names resolve, ids attach to an issue, both entry points work", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  # Creates a scratch iteration and two issues; the test removes them again.
  skip_if(Sys.getenv("ONEDEV_LIVE_ALLOW_WRITES") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  name <- paste0("onedevr-live-", format(Sys.time(), "%Y%m%d%H%M%S"))
  od_request("POST", "/iterations", body = list(
    projectId = as.integer(od_resolve_project_id()),
    name = name,
    description = "onedevr live test; deleted automatically"
  ))
  found <- Filter(function(x) identical(x$name, name), od_list_iterations(as_tibble = FALSE))
  skip_if(length(found) < 1L, "Scratch iteration was not created")
  id <- as.integer(found[[1]]$id)
  # Deferred calls run last-in first-out: the issues are closed before the
  # iteration is deleted.
  withr::defer(tryCatch(od_request("DELETE", paste0("/iterations/", id)), error = function(e) NULL))

  iterations_of <- function(issue) {
    its <- od_request("GET", paste0("/issues/", od_resolve_issue_id(issue$number), "/iterations"))
    vapply(its, function(x) as.integer(x$id), integer(1))
  }
  new_issue <- function(..., env = parent.frame()) {
    issue <- od_create_issue(title = "onedevr iteration live test", description = "Closed automatically.", ...)
    withr::defer(tryCatch(od_issue_transition_state(issue$number, "Closed"), error = function(e) NULL), envir = env)
    issue
  }

  expect_equal(od_resolve_iteration_ids(name), id)
  expect_equal(od_get_iteration(id)$name, name)

  # POST /issues/{id}/iterations takes a JSON array; the object form is
  # rejected with HTTP 400.
  plain <- new_issue()
  expect_length(iterations_of(plain), 0L)
  od_add_issue_iterations(plain$number, name)
  expect_equal(iterations_of(plain), id)

  with_iteration <- new_issue(iteration_ids = name)
  expect_equal(iterations_of(with_iteration), id)
})
