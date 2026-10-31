test_that(".od_quote_query_value wraps and escapes quotes and backslashes", {
  expect_equal(.od_quote_query_value("Open"), '"Open"')
  expect_equal(.od_quote_query_value('a"b'), '"a\\"b"')
  expect_equal(.od_quote_query_value("a\\b"), '"a\\\\b"')
  expect_equal(.od_quote_query_value('x\\"y'), '"x\\\\\\"y"')
  expect_equal(.od_quote_query_value(NULL), '""')
})

test_that("od_query_issues cannot be broken out of with a crafted state", {
  skip_if_not_installed("mockery")
  captured <- NULL
  mockery::stub(od_query_issues, "od_request", function(method, endpoint, query = NULL, ...) {
    captured <<- query$query
    list()
  })
  od_query_issues(state = 'Open" or "State" is not "Open', conn = list())
  expect_equal(
    captured,
    '"State" is "Open\\" or \\"State\\" is not \\"Open"'
  )
})

test_that("od_query_board_issues escapes the iteration name", {
  skip_if_not_installed("mockery")
  captured <- NULL
  mockery::stub(od_query_board_issues, "od_query_issues", function(query = NULL, ...) {
    captured <<- query
    list()
  })
  board <- list(name = "Dev", baseQuery = "", backlogBaseQuery = "")
  od_query_board_issues(board, iteration = 'Sprint "5"', conn = list())
  expect_equal(captured, '"Iteration" is "Sprint \\"5\\""')
})

test_that("UI number query variants are quoted", {
  expect_equal(
    .od_number_query_variants('grp/"p"', "7"),
    c(
      '"Number" is "grp/\\"p\\"#7"',
      '"Number" is "#7"',
      '"Number" is "7"'
    )
  )
})
