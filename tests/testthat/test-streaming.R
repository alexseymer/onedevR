test_that("od_stream_build_log requires callback function", {
  expect_error(
    od_stream_build_log(100, callback = "not_a_function", conn = list()),
    "`callback` must be a function"
  )
})

test_that("od_stream_build_log resolves build number and calls callback", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$calls <- list()

  mockery::stub(od_stream_build_log, "od_resolve_build_id", function(...) "501")
  mockery::stub(od_stream_build_log, ".od_request_raw", function(method, endpoint, ...) {
    expect_equal(method, "GET")
    expect_equal(endpoint, "/streaming/build-logs/501")
    raw(0)  # Empty log
  })
  mockery::stub(od_stream_build_log, ".od_parse_build_log_raw", function(raw) {
    c("line 1", "line 2", "line 3")
  })

  callback <- function(chunk, line_number, is_last) {
    captured$calls[[length(captured$calls) + 1L]] <- list(
      chunk = chunk,
      line_number = line_number,
      is_last = is_last
    )
  }

  result <- od_stream_build_log(100, callback = callback, conn = list())
  expect_equal(result, NULL)
  expect_equal(length(captured$calls), 3)
  expect_equal(captured$calls[[1]]$line_number, 1)
  expect_equal(captured$calls[[1]]$is_last, FALSE)
  expect_equal(captured$calls[[2]]$is_last, FALSE)
  expect_equal(captured$calls[[3]]$is_last, TRUE)
})

test_that("od_stream_build_log catches callback errors and continues", {
  skip_if_not_installed("mockery")

  call_count <- 0
  mockery::stub(od_stream_build_log, "od_resolve_build_id", function(...) "501")
  mockery::stub(od_stream_build_log, ".od_request_raw", function(...) raw(0))
  mockery::stub(od_stream_build_log, ".od_parse_build_log_raw", function(raw) {
    c("line 1", "line 2")
  })

  callback <- function(chunk, ...) {
    call_count <<- call_count + 1
    if (call_count == 1) {
      stop("Callback error")
    }
  }

  expect_warning(
    od_stream_build_log(100, callback = callback, conn = list()),
    "Error in callback at line 1"
  )
  expect_equal(call_count, 2)  # Called twice despite first error
})

test_that("od_stream_query_results requires functions", {
  expect_error(
    od_stream_query_results("not_a_function", function(...) {}),
    "`fetcher_fn` must be a function"
  )
  expect_error(
    od_stream_query_results(function(...) {}, "not_a_function"),
    "`callback` must be a function"
  )
})

test_that("od_stream_query_results validates chunk_size", {
  expect_error(
    od_stream_query_results(
      function(...) {},
      function(...) {},
      chunk_size = 0L
    ),
    "`chunk_size` must be >= 1"
  )
})

test_that("od_stream_query_results paginates and calls callback", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  captured$calls <- list()
  captured$fetcher_calls <- 0

  mockery::stub(od_stream_query_results, "do.call", function(fn, args, ...) {
    captured$fetcher_calls <- captured$fetcher_calls + 1
    offset <- args$offset
    # Simulate paginated results
    if (offset == 0) {
      data.frame(id = 1:50, name = paste0("item_", 1:50))
    } else {
      data.frame(id = 51:100, name = paste0("item_", 51:100))
    }
  })

  callback <- function(chunk, page, has_more) {
    captured$calls[[length(captured$calls) + 1L]] <- list(
      rows = nrow(chunk),
      page = page,
      has_more = has_more
    )
  }

  result <- od_stream_query_results(
    function(...) {},
    callback = callback,
    chunk_size = 50L,
    conn = list()
  )

  expect_equal(length(captured$calls), 2)
  expect_equal(captured$calls[[1]]$rows, 50)
  expect_equal(captured$calls[[1]]$page, 1)
  expect_equal(captured$calls[[1]]$has_more, TRUE)
  expect_equal(captured$calls[[2]]$has_more, FALSE)
  expect_equal(result$total_count, 100)
  expect_equal(result$page_count, 2)
})

test_that("od_stream_query_results respects max_pages limit", {
  skip_if_not_installed("mockery")

  page_count <- 0
  mockery::stub(od_stream_query_results, "do.call", function(fn, args, ...) {
    page_count <<- page_count + 1
    # Always return full pages
    data.frame(id = 1:100, name = paste0("item_", 1:100))
  })

  result <- od_stream_query_results(
    function(...) {},
    callback = function(...) {},
    chunk_size = 100L,
    max_pages = 3L,
    conn = list()
  )

  expect_equal(page_count, 3)
  expect_equal(result$page_count, 3)
})

test_that("od_stream_query_results with progress reports status", {
  skip_if_not_installed("mockery")

  mockery::stub(od_stream_query_results, "do.call", function(fn, args, ...) {
    offset <- args$offset
    if (offset < 100) {
      data.frame(id = offset + 1:50)
    } else {
      data.frame()
    }
  })

  expect_output(
    od_stream_query_results(
      function(...) {},
      callback = function(...) {},
      chunk_size = 50L,
      progress = TRUE,
      conn = list()
    ),
    "Page 1:"
  )
})

test_that("od_stream_query_results catches fetcher errors", {
  skip_if_not_installed("mockery")

  mockery::stub(od_stream_query_results, "do.call", function(...) {
    stop("API error")
  })

  expect_error(
    od_stream_query_results(
      function(...) {},
      callback = function(...) {},
      chunk_size = 50L,
      conn = list()
    ),
    "Error fetching page 1"
  )
})

test_that("od_chunked_foreach returns list of chunks when no callback", {
  skip_if_not_installed("mockery")

  mockery::stub(od_chunked_foreach, "od_stream_query_results", function(
    fetcher_fn, callback, chunk_size, as_tibble, progress, conn, ...
  ) {
    # Simulate calling callback with 2 chunks
    callback(data.frame(id = 1:50), 1, TRUE)
    callback(data.frame(id = 51:60), 2, FALSE)
    invisible(list(total_count = 60, page_count = 2, elapsed_time = 0.5))
  })

  chunks <- od_chunked_foreach(
    function(...) {},
    chunk_size = 50L,
    conn = list()
  )

  expect_equal(length(chunks), 2)
  expect_equal(nrow(chunks[[1]]), 50)
  expect_equal(nrow(chunks[[2]]), 10)
})

test_that("od_chunked_foreach calls callback when provided", {
  skip_if_not_installed("mockery")

  callback_calls <- 0
  mock_callback <- function(chunk, ...) {
    callback_calls <<- callback_calls + 1
  }

  mockery::stub(od_chunked_foreach, "od_stream_query_results", function(
    fetcher_fn, callback, chunk_size, as_tibble, progress, conn, ...
  ) {
    callback(data.frame(id = 1:50), 1, TRUE)
    callback(data.frame(id = 51:100), 2, FALSE)
    invisible(list(total_count = 100, page_count = 2, elapsed_time = 1))
  })

  result <- od_chunked_foreach(
    function(...) {},
    chunk_size = 50L,
    callback = mock_callback,
    conn = list()
  )

  expect_equal(result, NULL)
  expect_equal(callback_calls, 2)
})

test_that("od_chunked_foreach validates inputs", {
  expect_error(
    od_chunked_foreach("not_a_function"),
    "`fetcher_fn` must be a function"
  )
  expect_error(
    od_chunked_foreach(function(...) {}, callback = "not_a_function"),
    "`callback` must be a function or NULL"
  )
})

test_that("od_write_log_file requires file_path", {
  expect_error(
    od_write_log_file(100, file_path = "", conn = list()),
    "`file_path` is required"
  )
  expect_error(
    od_write_log_file(100, file_path = NULL, conn = list()),
    "`file_path` is required"
  )
})

test_that("od_write_log_file creates file and counts lines", {
  skip_if_not_installed("mockery")

  temp_file <- tempfile(fileext = ".txt")

  mockery::stub(od_write_log_file, "od_stream_build_log", function(
    build_number, callback, conn, use_internal_id, timeout
  ) {
    # Simulate streaming log with 3 lines
    callback("line 1", 1, FALSE)
    callback("line 2", 2, FALSE)
    callback("line 3", 3, TRUE)
  })

  result <- od_write_log_file(100, temp_file, conn = list())

  expect_true(file.exists(temp_file))
  expect_equal(result$file_path, temp_file)
  expect_equal(result$line_count, 3)
  expect_true(result$file_size > 0)

  # Verify file contents
  lines <- readLines(temp_file)
  expect_equal(length(lines), 3)
  expect_equal(lines[1], "line 1")

  unlink(temp_file)
})

test_that("od_write_log_file handles invalid file paths", {
  expect_error(
    od_write_log_file(100, "/invalid/path/that/does/not/exist/file.txt", conn = list()),
    "Cannot open file"
  )
})

test_that("od_write_log_file expands ~ in path", {
  skip_if_not_installed("mockery")

  expanded_path <- NULL
  mockery::stub(od_write_log_file, "od_stream_build_log", function(...) {})
  mockery::stub(od_write_log_file, "file", function(path, ...) {
    expanded_path <<- path
    file(tempfile())  # Return a valid connection
  })

  tryCatch(
    od_write_log_file(100, "~/test_file.log", conn = list()),
    error = function(e) NULL
  )

  expect_false(grepl("^~", expanded_path))
})

test_that("od_stream_query_results passes through extra arguments", {
  skip_if_not_installed("mockery")

  captured_args <- NULL
  mockery::stub(od_stream_query_results, "do.call", function(fn, args, ...) {
    captured_args <<- args
    data.frame()
  })

  od_stream_query_results(
    function(...) {},
    callback = function(...) {},
    chunk_size = 50L,
    query = "custom query",
    state = "Open",
    conn = list()
  )

  expect_equal(captured_args$query, "custom query")
  expect_equal(captured_args$state, "Open")
})

test_that("od_stream_build_log respects timeout parameter", {
  skip_if_not_installed("mockery")

  captured <- new.env(parent = emptyenv())
  mockery::stub(od_stream_build_log, "od_resolve_build_id", function(...) "501")
  mockery::stub(od_stream_build_log, ".od_request_raw", function(
    method, endpoint, query = NULL, body = NULL, conn = NULL, accept = "*/*", timeout = 60
  ) {
    captured$timeout <- timeout
    raw(0)
  })
  mockery::stub(od_stream_build_log, ".od_parse_build_log_raw", function(raw) character())

  od_stream_build_log(100, callback = function(...) {}, timeout = 120, conn = list())
  expect_equal(captured$timeout, 120)
})

test_that("od_stream_query_results with as_tibble parameter", {
  skip_if_not_installed("mockery")

  call_as_tibble <- NULL
  mockery::stub(od_stream_query_results, "do.call", function(fn, args, ...) {
    call_as_tibble <<- args$as_tibble
    data.frame()
  })

  od_stream_query_results(
    function(...) {},
    callback = function(...) {},
    as_tibble = FALSE,
    conn = list()
  )

  expect_equal(call_as_tibble, FALSE)
})
