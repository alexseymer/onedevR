sample_boards <- function() {
  list(
    list(
      name = "Development",
      baseQuery = '"Type" is not "Support Request"',
      backlogBaseQuery = '"Type" is not "Support Request" and ("State" is "Open")',
      identifyField = "State",
      columns = c("Open", "In Progress", "Closed")
    ),
    list(
      name = "Support",
      baseQuery = '"Type" is "Support Request"',
      backlogBaseQuery = "",
      identifyField = "State",
      columns = c("Open", "Closed")
    )
  )
}

test_that("od_list_boards extracts boardSpecs as tibble", {
  skip_if_not_installed("mockery")

  mockery::stub(od_list_boards, "od_get_project_setting", function(...) {
    list(issueSetting = list(boardSpecs = sample_boards()))
  })

  boards <- od_list_boards(conn = list())
  expect_s3_class(boards, "tbl_df")
  expect_equal(nrow(boards), 2)
  expect_equal(boards$name, c("Development", "Support"))
})

test_that("od_list_boards empty boardSpecs yields empty tibble", {
  skip_if_not_installed("mockery")

  mockery::stub(od_list_boards, "od_get_project_setting", function(...) {
    list(issueSetting = list())
  })
  boards <- od_list_boards(conn = list())
  expect_s3_class(boards, "tbl_df")
  expect_equal(nrow(boards), 0)
})

test_that("od_get_board finds by name and errors on miss", {
  skip_if_not_installed("mockery")

  mockery::stub(od_get_board, "od_list_boards", function(...) {
    sample_boards()
  })

  board <- od_get_board("Development", conn = list())
  expect_equal(board$name, "Development")
  expect_equal(board$identifyField, "State")

  expect_error(od_get_board("Missing", conn = list()), "was not found")
})

test_that("od_query_board_issues composes baseQuery and iteration", {
  skip_if_not_installed("mockery")

  board <- sample_boards()[[1]]
  mockery::stub(od_query_board_issues, "od_query_issues", function(
    query = NULL,
    state = NULL,
    count = 100L,
    offset = 0L,
    as_tibble = NULL,
    conn = NULL
  ) {
    expect_null(state)
    expect_equal(
      query,
      paste0(
        '("Type" is not "Support Request") and ',
        '"Iteration" is "Sprint 5"'
      )
    )
    expect_equal(count, 50L)
    list(list(id = 1, title = "a"))
  })

  out <- od_query_board_issues(
    board,
    iteration = "Sprint 5",
    count = 50L,
    as_tibble = FALSE,
    conn = list()
  )
  expect_equal(out[[1]]$title, "a")
})

test_that("od_query_board_issues uses backlogBaseQuery when backlog=TRUE", {
  skip_if_not_installed("mockery")

  mockery::stub(od_query_board_issues, "od_get_board", function(...) {
    sample_boards()[[1]]
  })
  mockery::stub(od_query_board_issues, "od_query_issues", function(
    query = NULL,
    state = NULL,
    ...
  ) {
    expect_null(state)
    expect_equal(
      query,
      '"Type" is not "Support Request" and ("State" is "Open")'
    )
    list()
  })

  od_query_board_issues("Development", backlog = TRUE, conn = list())
})

test_that("od_query_board_issues clears default_issue_state when query empty", {
  skip_if_not_installed("mockery")

  empty_board <- list(name = "Empty", baseQuery = "", backlogBaseQuery = "")
  mockery::stub(od_query_board_issues, "od_query_issues", function(
    query = NULL,
    state = NULL,
    conn = NULL,
    ...
  ) {
    expect_null(state)
    expect_true(is.null(query) || !nzchar(query))
    expect_equal(conn$default_issue_state, "")
    list()
  })

  od_query_board_issues(
    empty_board,
    conn = list(default_issue_state = "Open")
  )
})
