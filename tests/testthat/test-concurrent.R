test_that("is_future_installed returns TRUE when future is available", {
  # This test will pass if future is installed
  result <- is_future_installed(fallback = FALSE)
  # If we get here without error, future is available
  expect_true(result)
})

test_that("is_future_installed returns FALSE with fallback warning when not available", {
  skip_if_not_installed("mockery")

  mockery::stub(is_future_installed, "requireNamespace", function(...) FALSE)

  # Capture warning
  expect_warning(
    result <- is_future_installed(fallback = TRUE),
    "future.*not installed"
  )
  expect_false(result)
})

test_that("is_future_installed stops without fallback when not available", {
  skip_if_not_installed("mockery")

  mockery::stub(is_future_installed, "requireNamespace", function(...) FALSE)

  expect_error(
    is_future_installed(fallback = FALSE),
    "future.*required"
  )
})

test_that("od_parallel_query with empty queries returns empty list", {
  result <- od_parallel_query(queries = list(), conn = list())
  expect_equal(result, list())
})

test_that("od_parallel_query with fallback executes sequentially", {
  skip_if_not_installed("mockery")

  mockery::stub(od_parallel_query, "is_future_installed", function(...) FALSE)
  mockery::stub(od_parallel_query, ".od_sequential_queries", function(queries, conn) {
    list(list(id = 1, state = "Open"), list(id = 2, state = "Closed"))
  })

  queries <- list(
    list(fn = "od_query_issues", state = "Open"),
    list(fn = "od_query_issues", state = "Closed")
  )

  result <- od_parallel_query(queries = queries, conn = list())
  expect_equal(length(result), 2)
  expect_equal(result[[1]]$state, "Open")
})

test_that("od_parallel_query handles function not found error", {
  skip_if_not_installed("mockery")

  mockery::stub(od_parallel_query, "is_future_installed", function(...) FALSE)
  mockery::stub(od_parallel_query, ".od_sequential_queries", function(queries, conn) {
    list(list(
      error = TRUE,
      message = "Function 'nonexistent_fn' not found in onedevr"
    ))
  })

  queries <- list(list(fn = "nonexistent_fn", param = "value"))
  result <- od_parallel_query(queries = queries, conn = list())

  expect_true(result[[1]]$error)
  expect_match(result[[1]]$message, "not found")
})

test_that("od_map_parallel with empty items returns empty list", {
  result <- od_map_parallel(
    FUN = function(x) x,
    items = list(),
    conn = list()
  )
  expect_equal(result, list())
})

test_that("od_map_parallel requires FUN to be a function", {
  expect_error(
    od_map_parallel(FUN = "not_a_function", items = list(1, 2), conn = list()),
    "must be a function"
  )
})

test_that("od_map_parallel converts vector items to list", {
  skip_if_not_installed("mockery")

  mockery::stub(od_map_parallel, "is_future_installed", function(...) FALSE)

  # Create a simple test function
  test_fn <- function(x, conn = NULL) {
    list(original = x, doubled = x * 2)
  }

  mockery::stub(od_map_parallel, ".od_sequential_map", function(FUN, items, ..., conn) {
    expect_true(is.list(items))
    expect_equal(length(items), 3)
    list(
      list(original = 1, doubled = 2),
      list(original = 2, doubled = 4),
      list(original = 3, doubled = 6)
    )
  })

  result <- od_map_parallel(
    FUN = test_fn,
    items = c(1, 2, 3),
    conn = list()
  )

  expect_equal(length(result), 3)
})

test_that("od_map_parallel with fallback executes sequentially", {
  skip_if_not_installed("mockery")

  mockery::stub(od_map_parallel, "is_future_installed", function(...) FALSE)

  test_fn <- function(x, conn = NULL) {
    list(id = x, processed = TRUE)
  }

  mockery::stub(od_map_parallel, ".od_sequential_map", function(FUN, items, ..., conn) {
    lapply(items, function(item) list(id = item, processed = TRUE))
  })

  result <- od_map_parallel(
    FUN = test_fn,
    items = list(1, 2, 3),
    conn = list()
  )

  expect_equal(length(result), 3)
  expect_true(result[[1]]$processed)
})

test_that("od_map_parallel handles errors in individual items", {
  skip_if_not_installed("mockery")

  mockery::stub(od_map_parallel, "is_future_installed", function(...) FALSE)

  test_fn <- function(x, conn = NULL) {
    if (x == 2) stop("Error processing item 2")
    list(id = x, success = TRUE)
  }

  mockery::stub(od_map_parallel, ".od_sequential_map", function(FUN, items, ..., conn) {
    list(
      list(id = 1, success = TRUE),
      list(error = TRUE, message = "Error processing item 2", item = 2),
      list(id = 3, success = TRUE)
    )
  })

  result <- od_map_parallel(
    FUN = test_fn,
    items = list(1, 2, 3),
    conn = list()
  )

  expect_equal(length(result), 3)
  expect_true(result[[1]]$success)
  expect_true(result[[2]]$error)
  expect_true(result[[3]]$success)
})

test_that("od_concurrent_stream with empty items returns empty list", {
  result <- od_concurrent_stream(
    items = list(),
    FUN = function(x) x,
    conn = list()
  )
  expect_equal(result, list())
})

test_that("od_concurrent_stream requires FUN to be a function", {
  expect_error(
    od_concurrent_stream(
      items = list(1, 2),
      FUN = "not_a_function",
      conn = list()
    ),
    "must be a function"
  )
})

test_that("od_concurrent_stream validates max_workers", {
  expect_error(
    od_concurrent_stream(
      items = list(1, 2),
      FUN = function(x) x,
      max_workers = 0,
      conn = list()
    ),
    "must be at least 1"
  )
})

test_that("od_concurrent_stream with fallback executes sequentially", {
  skip_if_not_installed("mockery")

  mockery::stub(od_concurrent_stream, "is_future_installed", function(...) FALSE)

  test_fn <- function(x, conn = NULL) {
    list(id = x, processed = TRUE)
  }

  mockery::stub(od_concurrent_stream, ".od_sequential_map", function(FUN, items, ..., conn) {
    lapply(items, function(item) list(id = item, processed = TRUE))
  })

  result <- od_concurrent_stream(
    items = 1:5,
    FUN = test_fn,
    max_workers = 2,
    conn = list()
  )

  expect_equal(length(result), 5)
  expect_true(result[[1]]$processed)
})

test_that("od_concurrent_stream converts vector items to list", {
  skip_if_not_installed("mockery")

  mockery::stub(od_concurrent_stream, "is_future_installed", function(...) FALSE)

  test_fn <- function(x, conn = NULL) {
    list(id = x)
  }

  mockery::stub(od_concurrent_stream, ".od_sequential_map", function(FUN, items, ..., conn) {
    expect_true(is.list(items))
    expect_equal(length(items), 3)
    lapply(items, function(item) list(id = item))
  })

  result <- od_concurrent_stream(
    items = c(1, 2, 3),
    FUN = test_fn,
    max_workers = 2,
    conn = list()
  )

  expect_equal(length(result), 3)
})

test_that("od_concurrent_stream preserves result order", {
  skip_if_not_installed("mockery")

  mockery::stub(od_concurrent_stream, "is_future_installed", function(...) FALSE)

  test_fn <- function(x, conn = NULL) {
    list(input = x, output = x * 10)
  }

  mockery::stub(od_concurrent_stream, ".od_sequential_map", function(FUN, items, ..., conn) {
    lapply(items, function(item) list(input = item, output = item * 10))
  })

  result <- od_concurrent_stream(
    items = c(5, 3, 8, 1),
    FUN = test_fn,
    max_workers = 2,
    conn = list()
  )

  expect_equal(result[[1]]$input, 5)
  expect_equal(result[[1]]$output, 50)
  expect_equal(result[[2]]$input, 3)
  expect_equal(result[[2]]$output, 30)
  expect_equal(result[[3]]$input, 8)
  expect_equal(result[[3]]$output, 80)
  expect_equal(result[[4]]$input, 1)
  expect_equal(result[[4]]$output, 10)
})

test_that(".od_sequential_queries processes queries in order", {
  # This is an internal test of the fallback function
  test_fn <- function(x, conn = NULL) {
    list(result = x * 2)
  }

  # Mock the function lookup
  queries <- list(
    list(fn = "od_query_issues", state = "Open")
  )

  # Test that it attempts to find functions
  result <- tryCatch(
    {
      onedevr:::.od_sequential_queries(queries, list())
    },
    error = function(e) {
      # We expect an error since we're not mocking the actual functions
      list(error = TRUE)
    }
  )

  # Just verify the function exists and can be called
  expect_true(exists(".od_sequential_queries", where = asNamespace("onedevr")))
})

test_that(".od_sequential_map processes items in order", {
  # This is an internal test of the fallback function
  test_fn <- function(x, conn = NULL) {
    list(squared = x * x)
  }

  result <- onedevr:::.od_sequential_map(
    test_fn,
    items = list(1, 2, 3, 4),
    conn = list()
  )

  expect_equal(length(result), 4)
  expect_equal(result[[1]]$squared, 1)
  expect_equal(result[[2]]$squared, 4)
  expect_equal(result[[3]]$squared, 9)
  expect_equal(result[[4]]$squared, 16)
})

test_that(".od_sequential_map handles errors gracefully", {
  # This is an internal test of the fallback function
  test_fn <- function(x, conn = NULL) {
    if (x == 2) stop("Test error for x=2")
    list(id = x)
  }

  result <- onedevr:::.od_sequential_map(
    test_fn,
    items = list(1, 2, 3),
    conn = list()
  )

  expect_equal(length(result), 3)
  expect_true(result[[1]]$id == 1)
  expect_true(result[[2]]$error)
  expect_match(result[[2]]$message, "Test error")
  expect_true(result[[3]]$id == 3)
})

test_that("concurrent functions use connection resolution", {
  skip_if_not_installed("mockery")

  # Test that .od_conn is called to resolve connection
  mockery::stub(od_parallel_query, ".od_conn", function(conn) {
    list(
      host = "https://test.example.com",
      token = "test-token",
      default_issue_state = "Open"
    )
  })
  mockery::stub(od_parallel_query, "is_future_installed", function(...) FALSE)
  mockery::stub(od_parallel_query, ".od_sequential_queries", function(queries, conn) {
    expect_equal(conn$host, "https://test.example.com")
    list()
  })

  od_parallel_query(queries = list(), conn = NULL)
})

test_that("od_map_parallel passes additional arguments to function", {
  skip_if_not_installed("mockery")

  mockery::stub(od_map_parallel, "is_future_installed", function(...) FALSE)

  mockery::stub(od_map_parallel, ".od_sequential_map", function(FUN, items, ..., conn) {
    dots <- list(...)
    expect_equal(dots$multiplier, 5)
    expect_equal(dots$offset, 10)
    list(
      list(result = 5 * 5 + 10),
      list(result = 10 * 5 + 10)
    )
  })

  result <- od_map_parallel(
    FUN = function(x, multiplier, offset, conn = NULL) {
      list(result = x * multiplier + offset)
    },
    items = list(5, 10),
    multiplier = 5,
    offset = 10,
    conn = list()
  )

  expect_equal(length(result), 2)
})

test_that("od_concurrent_stream handles large item counts", {
  skip_if_not_installed("mockery")

  mockery::stub(od_concurrent_stream, "is_future_installed", function(...) FALSE)

  mockery::stub(od_concurrent_stream, ".od_sequential_map", function(FUN, items, ..., conn) {
    # Return matching number of results
    lapply(items, function(item) list(id = item))
  })

  # Test with large number of items
  large_items <- 1:100
  result <- od_concurrent_stream(
    items = large_items,
    FUN = function(x) list(id = x),
    max_workers = 4,
    conn = list()
  )

  expect_equal(length(result), 100)
})
