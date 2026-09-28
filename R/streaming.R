#' Stream build log output with callback processing
#'
#' Downloads the binary build log stream from OneDev and calls a callback function
#' for each parsed line. This allows processing large build logs without loading
#' the entire output into memory. Log lines are extracted from the streaming binary
#' protocol (see [od_get_build_log()]).
#'
#' @param build_number {character|numeric} UI build number (`100` or `"#100"`).
#' @param callback {function} Function called for each parsed line. Signature:
#'   `callback(chunk, line_number, is_last)` where:
#'   - `chunk` (character): the log line text
#'   - `line_number` (integer): 1-indexed line number
#'   - `is_last` (logical): `TRUE` if this is the last line
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `build_number` as the internal REST
#'   id (debugging only). Default: `FALSE`.
#' @param timeout {numeric} Seconds to wait for the full log stream (default `60`). Default: `60`.
#'
#' @return {invisible(NULL)} Returns invisibly; operates via callback side effects.
#' @endpoint GET /streaming/build-logs/{buildId}
#' @family streaming
#' @examples
#' \dontrun{
#' # Print each line with a line number prefix
#' od_stream_build_log(100, function(chunk, line_num, is_last) {
#'   cat(sprintf("%4d: %s\n", line_num, chunk))
#' })
#'
#' # Write to a file (see od_write_log_file for a convenience wrapper)
#' file_conn <- file("build_log.txt", "w")
#' od_stream_build_log(100, function(chunk, ...) {
#'   writeLines(chunk, file_conn)
#' })
#' close(file_conn)
#' }
#' @export
od_stream_build_log <- function(
  build_number,
  callback,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
) {
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }

  conn <- .od_conn(conn)
  build_id <- .od_resolve_entity_id(
    build_number,
    od_resolve_build_id,
    use_internal_id = use_internal_id,
    conn = conn
  )

  raw <- .od_request_raw(
    method = "GET",
    endpoint = paste0("/streaming/build-logs/", build_id),
    conn = conn,
    accept = "*/*",
    timeout = timeout
  )

  lines <- .od_parse_build_log_raw(raw)
  n_lines <- length(lines)

  for (i in seq_along(lines)) {
    is_last <- (i == n_lines)
    tryCatch(
      callback(lines[[i]], i, is_last),
      error = function(e) {
        warning(sprintf("Error in callback at line %d: %s", i, e$message), call. = FALSE)
      }
    )
  }

  invisible(NULL)
}

#' Stream large query results with chunking
#'
#' Repeatedly calls a fetcher function (e.g., [od_query_issues()]) to retrieve
#' paginated results, calling a callback for each page/chunk. This is useful for
#' processing large result sets that would be too large to load entirely into memory.
#'
#' @param fetcher_fn {function} A function that accepts `offset`, `count`, and optional
#'   `as_tibble` parameters (e.g., [od_query_issues()], [od_query_builds()]).
#'   Extra arguments are passed via `...`.
#' @param callback {function} Function called for each chunk. Signature:
#'   `callback(chunk_df, page_number, has_more)` where:
#'   - `chunk_df` (tibble or list): the results chunk
#'   - `page_number` (integer): 1-indexed page number
#'   - `has_more` (logical): `TRUE` if more pages exist
#' @param chunk_size {integer} Number of results per page (default `100`). Default: `100L`.
#' @param max_pages {integer} Safety cap on number of pages (default `100`). Default: `100L`.
#' @param as_tibble {logical} If `TRUE` (default), return results as tibbles to the callback.
#'   Default: `NULL` (uses fetcher default).
#' @param progress {logical} If `TRUE`, print progress messages with line count and elapsed time
#'   (default `FALSE`). Default: `FALSE`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param ... Additional arguments forwarded to `fetcher_fn` (e.g. `state = "Open"`, `query = ...`).
#'
#' @return {invisible(list)} Invisibly returns a summary list with:
#'   - `total_count`: total number of results processed
#'   - `page_count`: total number of pages fetched
#'   - `elapsed_time`: elapsed time in seconds
#' @family streaming
#' @examples
#' \dontrun{
#' # Process all open issues, 50 at a time
#' od_stream_query_results(
#'   od_query_issues,
#'   state = "Open",
#'   chunk_size = 50L,
#'   callback = function(chunk_df, page_num, has_more) {
#'     cat(sprintf("Page %d: %d issues\n", page_num, nrow(chunk_df)))
#'   }
#' )
#'
#' # With progress reporting
#' od_stream_query_results(
#'   od_query_builds,
#'   status = "successful",
#'   chunk_size = 100L,
#'   progress = TRUE,
#'   callback = function(chunk_df, ...) {
#'     # process each chunk
#'   }
#' )
#' }
#' @export
od_stream_query_results <- function(
  fetcher_fn,
  callback,
  chunk_size = 100L,
  max_pages = 100L,
  as_tibble = NULL,
  progress = FALSE,
  conn = NULL,
  ...
) {
  if (!is.function(fetcher_fn)) {
    stop("`fetcher_fn` must be a function.", call. = FALSE)
  }
  if (!is.function(callback)) {
    stop("`callback` must be a function.", call. = FALSE)
  }

  chunk_size <- as.integer(chunk_size)[1]
  max_pages <- as.integer(max_pages)[1]
  if (chunk_size < 1L) {
    stop("`chunk_size` must be >= 1.", call. = FALSE)
  }

  start_time <- Sys.time()
  offset <- 0L
  page <- 0L
  total_count <- 0L
  formals_names <- names(formals(fetcher_fn))

  for (i in seq_len(max_pages)) {
    args <- list(..., offset = offset, count = chunk_size)
    if ("as_tibble" %in% formals_names) {
      args$as_tibble <- as_tibble
    }
    if ("conn" %in% formals_names) {
      args$conn <- conn
    }

    chunk <- tryCatch(
      do.call(fetcher_fn, args),
      error = function(e) {
        stop(sprintf("Error fetching page %d: %s", i, e$message), call. = FALSE)
      }
    )

    n_chunk <- if (inherits(chunk, "data.frame")) {
      nrow(chunk)
    } else {
      length(.od_normalize_collection(chunk))
    }

    total_count <- total_count + n_chunk
    page <- i
    has_more <- (n_chunk >= chunk_size)

    if (isTRUE(progress)) {
      elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
      cat(sprintf(
        "Page %d: %d items (total: %d, elapsed: %.1fs)\n",
        page, n_chunk, total_count, elapsed
      ))
    }

    tryCatch(
      callback(chunk, page, has_more),
      error = function(e) {
        warning(sprintf("Error in callback at page %d: %s", page, e$message), call. = FALSE)
      }
    )

    if (!has_more) {
      break
    }
    offset <- offset + chunk_size
  }

  elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
  invisible(list(
    total_count = total_count,
    page_count = page,
    elapsed_time = elapsed
  ))
}

#' Process results in fixed-size chunks
#'
#' A convenience wrapper around [od_stream_query_results()] for batch processing.
#' If no callback is provided, yields results as a list of chunks (useful with
#' `lapply()` or for saving to disk). If a callback is provided, it is called
#' for each chunk and the return value is `NULL`.
#'
#' @param fetcher_fn {function} A function that accepts `offset`, `count`, and optional
#'   `as_tibble` parameters (e.g., [od_query_issues()], [od_query_builds()]).
#' @param chunk_size {integer} Number of results per chunk (default `100`). Default: `100L`.
#' @param callback {function} Optional callback. If provided, called for each chunk
#'   and results are not returned. Signature: `callback(chunk_df, chunk_num, has_more)`.
#'   Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param ... Additional arguments forwarded to `fetcher_fn`.
#'
#' @return {list} If `callback = NULL`: a list of chunks (each chunk is a tibble or list).
#'   Otherwise: `invisible(NULL)`.
#' @family streaming
#' @examples
#' \dontrun{
#' # Collect all issues in 50-item chunks, return as list
#' chunks <- od_chunked_foreach(od_query_issues, chunk_size = 50L, state = "Open")
#' lapply(chunks, function(chunk) {
#'   cat(sprintf("Chunk with %d issues\n", nrow(chunk)))
#' })
#'
#' # Or use with a callback and side effects
#' od_chunked_foreach(
#'   od_query_builds,
#'   chunk_size = 100L,
#'   callback = function(chunk, chunk_num, ...) {
#'     write.csv(chunk, sprintf("builds_chunk_%d.csv", chunk_num))
#'   }
#' )
#' }
#' @export
od_chunked_foreach <- function(
  fetcher_fn,
  chunk_size = 100L,
  callback = NULL,
  conn = NULL,
  ...
) {
  if (!is.function(fetcher_fn)) {
    stop("`fetcher_fn` must be a function.", call. = FALSE)
  }

  chunks <- list()

  if (is.null(callback)) {
    # Collector mode: gather chunks in a list
    callback_impl <- function(chunk, page, has_more) {
      chunks[[length(chunks) + 1L]] <<- chunk
    }
  } else {
    if (!is.function(callback)) {
      stop("`callback` must be a function or NULL.", call. = FALSE)
    }
    callback_impl <- callback
  }

  od_stream_query_results(
    fetcher_fn = fetcher_fn,
    callback = callback_impl,
    chunk_size = chunk_size,
    as_tibble = NULL,
    progress = FALSE,
    conn = conn,
    ...
  )

  if (is.null(callback)) {
    invisible(chunks)
  } else {
    invisible(NULL)
  }
}

#' Write build log to a file
#'
#' Convenience wrapper around [od_stream_build_log()] that writes the build log
#' to a file line-by-line. Returns metadata about the operation.
#'
#' @param build_number {character|numeric} UI build number (`100` or `"#100"`).
#' @param file_path {character} Output file path. Created if it doesn't exist;
#'   existing files are overwritten. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `build_number` as the internal REST
#'   id (debugging only). Default: `FALSE`.
#' @param timeout {numeric} Seconds to wait for the full log stream (default `60`). Default: `60`.
#'
#' @return {invisible(list)} Invisibly returns a summary list with:
#'   - `file_path`: the output file path
#'   - `line_count`: number of lines written
#'   - `file_size`: file size in bytes
#' @family streaming
#' @examples
#' \dontrun{
#' result <- od_write_log_file(100, "~/build_100.log")
#' cat(sprintf("Wrote %d lines to %s\n", result$line_count, result$file_path))
#' }
#' @export
od_write_log_file <- function(
  build_number,
  file_path,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
) {
  file_path <- as.character(file_path)[1]
  if (!nzchar(file_path)) {
    stop("`file_path` is required.", call. = FALSE)
  }

  # Expand path to handle ~ and other shell expansions
  file_path <- path.expand(file_path)

  line_count <- 0L
  file_conn <- tryCatch(
    file(file_path, "w"),
    error = function(e) {
      stop(sprintf("Cannot open file '%s': %s", file_path, e$message), call. = FALSE)
    }
  )

  on.exit(close(file_conn), add = TRUE)

  od_stream_build_log(
    build_number = build_number,
    callback = function(chunk, line_number, is_last) {
      tryCatch(
        writeLines(chunk, file_conn),
        error = function(e) {
          stop(sprintf("Error writing line %d: %s", line_number, e$message), call. = FALSE)
        }
      )
      line_count <<- line_number
    },
    conn = conn,
    use_internal_id = use_internal_id,
    timeout = timeout
  )

  file_size <- tryCatch(
    file.info(file_path)$size,
    error = function(e) NA_real_
  )

  invisible(list(
    file_path = file_path,
    line_count = line_count,
    file_size = file_size
  ))
}
