test_that("od_batch_create_issues handles empty input", {
  result <- od_batch_create_issues(list(), conn = list())
  expect_equal(result$created, list())
  expect_equal(result$numbers, numeric(0))
  expect_equal(result$errors, list())
  expect_match(result$summary, "No issues to create")
})

test_that("od_batch_create_issues converts tibble to list specs", {
  skip_if_not_installed("mockery")

  mock_call_count <- new.env(parent = emptyenv())
  mock_call_count$count <- 0

  mockery::stub(od_batch_create_issues, "od_create_issue", function(
    title, description = "", fields = list(), iteration_ids = NULL, conn = NULL) {
    mock_call_count$count <- mock_call_count$count + 1
    list(id = mock_call_count$count, number = 10 + mock_call_count$count, title = title)
  })

  issues <- data.frame(
    title = c("Issue 1", "Issue 2"),
    description = c("Desc 1", "Desc 2"),
    stringsAsFactors = FALSE
  )

  result <- od_batch_create_issues(issues, progress = FALSE, conn = list())
  expect_equal(mock_call_count$count, 2)
  expect_equal(length(result$created), 2)
  expect_equal(result$numbers, c(11, 12))
  expect_equal(result$errors, list())
})

test_that("od_batch_create_issues creates issues with default title", {
  skip_if_not_installed("mockery")

  captured_titles <- new.env(parent = emptyenv())
  captured_titles$titles <- character(0)

  mockery::stub(od_batch_create_issues, "od_create_issue", function(
    title, description = "", fields = list(), iteration_ids = NULL, conn = NULL) {
    captured_titles$titles <- c(captured_titles$titles, title)
    list(id = 1, number = 10, title = title)
  })

  # Create with minimal specs
  specs <- list(
    list(), # Will default to "Issue 1"
    list(title = "Custom Title") # Will use provided title
  )

  result <- od_batch_create_issues(specs, progress = FALSE, conn = list())
  expect_equal(captured_titles$titles, c("Issue 1", "Custom Title"))
})

test_that("od_batch_create_issues handles creation errors gracefully", {
  skip_if_not_installed("mockery")

  call_count <- new.env(parent = emptyenv())
  call_count$count <- 0

  mockery::stub(od_batch_create_issues, "od_create_issue", function(
    title, description = "", fields = list(), iteration_ids = NULL, conn = NULL) {
    call_count$count <- call_count$count + 1
    if (call_count$count == 2) {
      stop("API error: invalid field")
    }
    list(id = call_count$count, number = 10 + call_count$count, title = title)
  })

  specs <- list(
    list(title = "Issue 1"),
    list(title = "Issue 2 - will fail"),
    list(title = "Issue 3")
  )

  result <- od_batch_create_issues(specs, progress = FALSE, conn = list())
  expect_equal(length(result$created), 2)
  expect_equal(length(result$errors), 1)
  expect_equal(result$errors[[1]]$title, "Issue 2 - will fail")
  expect_match(result$errors[[1]]$error, "API error")
  expect_match(result$summary, "with 1 errors")
})

test_that("od_batch_create_issues passes iteration_ids correctly", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$iteration_ids <- NULL

  mockery::stub(od_batch_create_issues, "od_create_issue", function(
    title, description = "", fields = list(), iteration_ids = NULL, conn = NULL) {
    captured$iteration_ids <- iteration_ids
    list(id = 1, number = 10, title = title)
  })

  specs <- list(
    list(title = "Issue with iterations", iteration_ids = c(17L, 18L))
  )

  result <- od_batch_create_issues(specs, progress = FALSE, conn = list())
  expect_equal(captured$iteration_ids, c(17L, 18L))
})

test_that("od_batch_update_issues handles empty input", {
  result <- od_batch_update_issues(numeric(0), conn = list())
  expect_equal(result$updated, list())
  expect_equal(result$count, 0L)
  expect_equal(result$errors, list())
  expect_match(result$summary, "No issues to update")
})

test_that("od_batch_update_issues requires updates list", {
  expect_error(
    od_batch_update_issues(c(10, 15), updates = NULL, conn = list()),
    "must be a non-empty named list"
  )
  expect_error(
    od_batch_update_issues(c(10, 15), updates = list(), conn = list()),
    "must be a non-empty named list"
  )
})

test_that("od_batch_update_issues validates update keys", {
  expect_error(
    od_batch_update_issues(
      c(10, 15),
      updates = list(invalid_key = "value"),
      conn = list()
    ),
    "Invalid update keys"
  )
})

test_that("od_batch_update_issues handles selective updates", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$calls <- list()

  mockery::stub(od_batch_update_issues, "od_issue_set_title", function(issue_number, title, conn = NULL) {
    captured$calls[[length(captured$calls) + 1]] <- list(func = "set_title", number = issue_number)
    list(id = 1, number = issue_number, title = title)
  })
  mockery::stub(od_batch_update_issues, "od_issue_set_fields", function(issue_number, fields, conn = NULL) {
    captured$calls[[length(captured$calls) + 1]] <- list(func = "set_fields", number = issue_number)
    list(id = 1, number = issue_number, fields = fields)
  })
  mockery::stub(od_batch_update_issues, "od_issue_transition_state", function(issue_number, state, conn = NULL) {
    captured$calls[[length(captured$calls) + 1]] <- list(func = "transition_state", number = issue_number)
    list(id = 1, number = issue_number, state = state)
  })

  result <- od_batch_update_issues(
    c(10, 15),
    updates = list(
      title = "New title",
      fields = list(Priority = "High"),
      state = "Closed"
    ),
    progress = FALSE,
    conn = list()
  )

  expect_equal(result$count, 2)
  expect_equal(length(result$errors), 0)
  # Should call 3 functions per issue (title, fields, state)
  expect_equal(length(captured$calls), 6)
})

test_that("od_batch_update_issues handles update errors", {
  skip_if_not_installed("mockery")

  call_count <- new.env(parent = emptyenv())
  call_count$count <- 0

  mockery::stub(od_batch_update_issues, "od_issue_set_title", function(issue_number, title, conn = NULL) {
    call_count$count <- call_count$count + 1
    if (issue_number == 15) {
      stop("Issue not found")
    }
    list(id = 1, number = issue_number, title = title)
  })

  result <- od_batch_update_issues(
    c(10, 15),
    updates = list(title = "New title"),
    progress = FALSE,
    conn = list()
  )

  expect_equal(result$count, 1)
  expect_equal(length(result$errors), 1)
  expect_equal(result$errors[[1]]$issue_number, 15)
  expect_match(result$errors[[1]]$error, "Issue not found")
})

test_that("od_batch_link_issues_prs requires tibble/dataframe", {
  expect_error(
    od_batch_link_issues_prs(c(10, 15), conn = list()),
    "must be a tibble or data.frame"
  )
})

test_that("od_batch_link_issues_prs requires correct columns", {
  links <- data.frame(
    issue_number = c(10, 15),
    pr_number = c(42, 43)
  )
  expect_error(
    od_batch_link_issues_prs(links, conn = list()),
    "must have `issue_number` and `pull_request_number` columns"
  )
})

test_that("od_batch_link_issues_prs handles empty input", {
  links <- data.frame(
    issue_number = numeric(0),
    pull_request_number = numeric(0)
  )
  result <- od_batch_link_issues_prs(links, conn = list())
  expect_equal(result$linked, numeric(0))
  expect_equal(result$count, 0L)
  expect_equal(result$errors, list())
  expect_match(result$summary, "No links to create")
})

test_that("od_batch_link_issues_prs creates multiple links", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$calls <- list()

  mockery::stub(od_batch_link_issues_prs, "od_link_issue_to_pull_request", function(
    issue_number, pull_request_number, conn = NULL) {
    captured$calls[[length(captured$calls) + 1]] <- list(
      issue = issue_number,
      pr = pull_request_number
    )
    list(ok = TRUE)
  })

  links <- data.frame(
    issue_number = c(10, 15, 20),
    pull_request_number = c(42, 43, 44)
  )

  result <- od_batch_link_issues_prs(links, progress = FALSE, conn = list())
  expect_equal(result$count, 3)
  expect_equal(result$linked, c(10, 15, 20))
  expect_equal(length(captured$calls), 3)
  expect_equal(captured$calls[[1]]$issue, 10)
  expect_equal(captured$calls[[1]]$pr, 42)
})

test_that("od_batch_link_issues_prs handles link errors", {
  skip_if_not_installed("mockery")

  call_count <- new.env(parent = emptyenv())
  call_count$count <- 0

  mockery::stub(od_batch_link_issues_prs, "od_link_issue_to_pull_request", function(
    issue_number, pull_request_number, conn = NULL) {
    call_count$count <- call_count$count + 1
    if (call_count$count == 2) {
      stop("PR not found")
    }
    list(ok = TRUE)
  })

  links <- data.frame(
    issue_number = c(10, 15, 20),
    pull_request_number = c(42, 43, 44)
  )

  result <- od_batch_link_issues_prs(links, progress = FALSE, conn = list())
  expect_equal(result$count, 2)
  expect_equal(length(result$errors), 1)
  expect_equal(result$errors[[1]]$issue_number, 15)
  expect_equal(result$errors[[1]]$pull_request_number, 43)
  expect_match(result$errors[[1]]$error, "PR not found")
})

test_that("od_batch_transition_issues handles empty input", {
  result <- od_batch_transition_issues(numeric(0), "Closed", conn = list())
  expect_equal(result$transitioned, list())
  expect_equal(result$count, 0L)
  expect_equal(result$errors, list())
  expect_match(result$summary, "No issues to transition")
})

test_that("od_batch_transition_issues requires target_state", {
  expect_error(
    od_batch_transition_issues(c(10, 15), NULL, conn = list()),
    "target_state"
  )
  expect_error(
    od_batch_transition_issues(c(10, 15), "", conn = list()),
    "target_state"
  )
})

test_that("od_batch_transition_issues transitions multiple issues", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$calls <- list()

  mockery::stub(od_batch_transition_issues, "od_issue_transition_state", function(
    issue_number, state, conn = NULL) {
    captured$calls[[length(captured$calls) + 1]] <- list(
      number = issue_number,
      state = state
    )
    list(id = 1, number = issue_number, state = state)
  })

  result <- od_batch_transition_issues(
    c(10, 15, 20),
    "Closed",
    progress = FALSE,
    conn = list()
  )

  expect_equal(result$count, 3)
  expect_equal(length(result$transitioned), 3)
  expect_equal(length(captured$calls), 3)
  expect_equal(captured$calls[[1]]$state, "Closed")
  expect_equal(captured$calls[[2]]$state, "Closed")
  expect_equal(captured$calls[[3]]$state, "Closed")
  expect_match(result$summary, "Transitioned 3 of 3")
})

test_that("od_batch_transition_issues handles transition errors", {
  skip_if_not_installed("mockery")

  call_count <- new.env(parent = emptyenv())
  call_count$count <- 0

  mockery::stub(od_batch_transition_issues, "od_issue_transition_state", function(
    issue_number, state, conn = NULL) {
    call_count$count <- call_count$count + 1
    if (call_count$count == 2) {
      stop("Invalid state transition")
    }
    list(id = 1, number = issue_number, state = state)
  })

  result <- od_batch_transition_issues(
    c(10, 15, 20),
    "Closed",
    progress = FALSE,
    conn = list()
  )

  expect_equal(result$count, 2)
  expect_equal(length(result$errors), 1)
  expect_equal(result$errors[[1]]$issue_number, 15)
  expect_equal(result$errors[[1]]$target_state, "Closed")
  expect_match(result$errors[[1]]$error, "Invalid state transition")
})

test_that("od_batch_transition_issues strips hash from issue numbers", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$numbers <- character(0)

  mockery::stub(od_batch_transition_issues, "od_issue_transition_state", function(
    issue_number, state, conn = NULL) {
    captured$numbers <- c(captured$numbers, issue_number)
    list(id = 1, number = as.numeric(issue_number), state = state)
  })

  result <- od_batch_transition_issues(
    c("#10", "#15", "20"),
    "Closed",
    progress = FALSE,
    conn = list()
  )

  expect_equal(captured$numbers, c("10", "15", "20"))
})
