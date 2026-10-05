#' Check if future package is available
#'
#' Helper function to verify that the `future` package is installed.
#' If not available, suggests installation and can optionally fall back
#' to sequential processing.
#'
#' @param fallback {logical} If `TRUE` (default), issues a warning and
#'   returns `FALSE` to trigger fallback to sequential processing.
#'   If `FALSE`, stops with an error. Default: `TRUE`.
#' @return {logical} `TRUE` if `future` is installed, `FALSE` if not
#'   and fallback is enabled.
#' @examples
#' \dontrun{
#' if (is_future_installed()) {
#'   # Use future-based parallel processing
#' }
#' }
#' @export
is_future_installed <- function(fallback = TRUE) {
  if (requireNamespace("future", quietly = TRUE)) {
    return(TRUE)
  }

  if (isTRUE(fallback)) {
    warning(
      "The `future` package is not installed. ",
      "Install it with: install.packages('future'). ",
      "Falling back to sequential processing.",
      call. = FALSE
    )
    return(FALSE)
  } else {
    stop(
      "The `future` package is required for concurrent operations. ",
      "Install it with: install.packages('future').",
      call. = FALSE
    )
  }
}

#' Run multiple queries concurrently
#'
#' Execute a list of query specifications in parallel using futures.
#' Each query spec is a list containing a function name and its arguments.
#' Useful for batch retrieving data from multiple endpoints without blocking.
#'
#' If `future` is not installed, falls back to sequential execution
#' with a warning.
#'
#' @param queries {list} List of query specifications. Each element should be
#'   a list with `fn` (function name as string) and named arguments for that
#'   function. Example: `list(list(fn = "od_query_issues", state = "Open"),
#'   list(fn = "od_query_builds", status = "successful"))`. Default: `list()`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()].
#'   Default: `NULL`.
#'
#' @return {list} A list of results in the same order as the input queries.
#'   If a query fails, the error message is returned in its position.
#' @family concurrent
#' @examples
#' \dontrun{
#' results <- od_parallel_query(
#'   queries = list(
#'     list(fn = "od_query_issues", state = "Open", count = 50L),
#'     list(fn = "od_query_issues", state = "Closed", count = 50L),
#'     list(fn = "od_query_builds", status = "successful")
#'   ),
#'   conn = conn
#' )
#' }
#' @export
od_parallel_query <- function(queries = list(), conn = NULL) {
  conn <- .od_conn(conn)

  # Validate queries
  if (!is.list(queries) || length(queries) == 0) {
    return(list())
  }

  # Fall back to sequential if future not available
  if (!is_future_installed(fallback = TRUE)) {
    return(.od_sequential_queries(queries, conn))
  }

  # Prepare futures for each query
  futures <- lapply(queries, function(query_spec) {
    future::future({
      tryCatch(
        {
          fn_name <- query_spec$fn
          fn_args <- query_spec[names(query_spec) != "fn"]
          fn_args$conn <- conn

          fn <- getNamespace("onedevr")[[fn_name]]
          if (is.null(fn) || !is.function(fn)) {
            stop(paste0("Function '", fn_name, "' not found in onedevr"), call. = FALSE)
          }

          do.call(fn, fn_args)
        },
        error = function(e) {
          list(error = TRUE, message = conditionMessage(e))
        }
      )
    }, evaluator = future::sequential)
  })

  # Collect results
  results <- lapply(futures, future::value)
  results
}

#' Apply a function to items in parallel
#'
#' Execute a function across multiple items concurrently. The function is
#' called once per item in the list/vector with that item and any additional
#' arguments passed via `...`. Results maintain the same order as input items.
#'
#' If a single item fails, that position in the result list contains an error
#' message, while other items continue processing. If `future` is not installed,
#' falls back to sequential execution.
#'
#' @param FUN {function} Function to apply to each item. Called as
#'   `FUN(item, ..., conn = conn)`.
#' @param items {list|vector} Items to process. Each will be passed as the
#'   first argument to `FUN`. Default: `list()`.
#' @param ... Additional arguments passed to `FUN` for every item.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()].
#'   Default: `NULL`.
#'
#' @return {list} Results from applying `FUN` to each item, in the same order.
#'   Failed items contain an error message.
#' @family concurrent
#' @examples
#' \dontrun{
#' # Fetch multiple issues in parallel
#' issues <- od_map_parallel(
#'   FUN = od_get_issue,
#'   items = c(1, 2, 3, 4, 5),
#'   conn = conn
#' )
#'
#' # Transition multiple issues to "Closed" in parallel
#' od_map_parallel(
#'   FUN = od_issue_transition_state,
#'   items = c(1, 2, 3),
#'   state = "Closed",
#'   conn = conn
#' )
#' }
#' @export
od_map_parallel <- function(FUN, items = list(), ..., conn = NULL) {
  conn <- .od_conn(conn)

  # Validate inputs
  if (!is.function(FUN)) {
    stop("`FUN` must be a function.", call. = FALSE)
  }

  if (length(items) == 0) {
    return(list())
  }

  # Convert single values to list
  if (!is.list(items)) {
    items <- as.list(items)
  }

  # Fall back to sequential if future not available
  if (!is_future_installed(fallback = TRUE)) {
    return(.od_sequential_map(FUN, items, ..., conn = conn))
  }

  # Prepare futures for each item
  dots <- list(...)
  futures <- lapply(items, function(item) {
    future::future({
      tryCatch(
        {
          call_args <- c(list(item), dots, list(conn = conn))
          do.call(FUN, call_args)
        },
        error = function(e) {
          list(error = TRUE, message = conditionMessage(e), item = item)
        }
      )
    }, evaluator = future::sequential)
  })

  # Collect results
  results <- lapply(futures, future::value)
  results
}

#' Process a stream of items with concurrent workers
#'
#' Apply a function across a potentially large list of items using a
#' configurable number of concurrent workers. Useful for bulk operations
#' with built-in rate limiting and worker pool management.
#'
#' If `future` is not installed, falls back to sequential execution.
#'
#' @param items {list|vector} Items to process.
#' @param FUN {function} Function to apply to each item.
#'   Called as `FUN(item, ..., conn = conn)`.
#' @param max_workers {integer} Maximum number of concurrent workers (default `4`).
#'   Set lower for rate-limited APIs. Default: `4`.
#' @param ... Additional arguments passed to `FUN` for every item.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()].
#'   Default: `NULL`.
#'
#' @return {list} Combined results from all items, in the same order.
#'   Failed items contain error messages.
#' @family concurrent
#' @examples
#' \dontrun{
#' # Bulk update many issues with 2 workers to avoid rate limiting
#' results <- od_concurrent_stream(
#'   items = 1:100,
#'   FUN = function(issue_num) {
#'     od_issue_set_fields(
#'       issue_number = issue_num,
#'       fields = list(Status = "In Progress")
#'     )
#'   },
#'   max_workers = 2,
#'   conn = conn
#' )
#' }
#' @export
od_concurrent_stream <- function(
  items,
  FUN,
  max_workers = 4L,
  ...,
  conn = NULL
) {
  conn <- .od_conn(conn)

  # Validate inputs
  if (!is.function(FUN)) {
    stop("`FUN` must be a function.", call. = FALSE)
  }

  if (length(items) == 0) {
    return(list())
  }

  max_workers <- as.integer(max_workers[1])
  if (max_workers < 1) {
    stop("`max_workers` must be at least 1.", call. = FALSE)
  }

  # Convert single values to list
  if (!is.list(items)) {
    items <- as.list(items)
  }

  # Fall back to sequential if future not available
  if (!is_future_installed(fallback = TRUE)) {
    return(.od_sequential_map(FUN, items, ..., conn = conn))
  }

  # Process items in batches using workers
  dots <- list(...)
  all_results <- vector("list", length(items))

  # Create futures for all items
  futures <- lapply(seq_along(items), function(idx) {
    item <- items[[idx]]
    future::future({
      tryCatch(
        {
          call_args <- c(list(item), dots, list(conn = conn))
          do.call(FUN, call_args)
        },
        error = function(e) {
          list(error = TRUE, message = conditionMessage(e), item = item)
        }
      )
    }, evaluator = future::sequential)
  })

  # Collect results preserving order
  all_results <- lapply(futures, future::value)
  all_results
}

# ============================================================================
# Sequential fallbacks for when future is not available
# ============================================================================

#' Sequential query execution fallback
#' @noRd
.od_sequential_queries <- function(queries, conn) {
  lapply(queries, function(query_spec) {
    tryCatch(
      {
        fn_name <- query_spec$fn
        fn_args <- query_spec[names(query_spec) != "fn"]
        fn_args$conn <- conn

        fn <- getNamespace("onedevr")[[fn_name]]
        if (is.null(fn) || !is.function(fn)) {
          stop(paste0("Function '", fn_name, "' not found in onedevr"), call. = FALSE)
        }

        do.call(fn, fn_args)
      },
      error = function(e) {
        list(error = TRUE, message = conditionMessage(e))
      }
    )
  })
}

#' Sequential map execution fallback
#' @noRd
.od_sequential_map <- function(FUN, items, ..., conn) {
  dots <- list(...)
  lapply(items, function(item) {
    tryCatch(
      {
        call_args <- c(list(item), dots, list(conn = conn))
        do.call(FUN, call_args)
      },
      error = function(e) {
        list(error = TRUE, message = conditionMessage(e), item = item)
      }
    )
  })
}
