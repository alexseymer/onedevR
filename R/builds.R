#' Query OneDev builds
#'
#' @param query Raw OneDev build query string (see `tod build get-query-description`
#'   / OneDev query DSL). Example: `'"Number" is "group/project#100"'`.
#' @param status Optional status filter (e.g. `"SUCCESSFUL"`, `"FAILED"`).
#'   Combined with `query` via `and`.
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#'
#' @return A tibble of builds (default), or a list when `as_tibble = FALSE`.
#' @export
od_query_builds <- function(
  query = NULL,
  status = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- trimws(as.character(query %||% "")[1])
  status <- trimws(as.character(status %||% "")[1])

  if (nzchar(status)) {
    status_clause <- paste0('"Status" is "', status, '"')
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", status_clause)
    } else {
      status_clause
    }
  }

  payload <- od_request(
    method = "GET",
    endpoint = "/builds",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a single build by UI number
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST
#'   id (debugging only).
#' @return Parsed build object (list).
#' @export
od_get_build <- function(build_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  build_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
  od_request("GET", paste0("/builds/", build_id), conn = conn)
}

#' Get parameters for a build
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return Parsed params payload (list).
#' @export
od_get_build_params <- function(build_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  build_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
  od_request("GET", paste0("/builds/", build_id, "/params"), conn = conn)
}

#' Read a signed big-endian 32-bit integer from raw bytes
#' @keywords internal
.od_read_i32be <- function(bytes, pos) {
  b <- as.integer(bytes[pos:(pos + 3L)])
  u <- b[[1]] * 16777216 + b[[2]] * 65536 + b[[3]] * 256 + b[[4]]
  if (u >= 2147483648) u - 4294967296 else u
}

#' Parse OneDev streaming build-log binary payload to plain text
#'
#' Protocol (from tod / OneDev): 4-byte big-endian signed length, then either a
#' status string (negative length) or a JSON log entry (positive length) whose
#' `messages[].text` fields are concatenated.
#'
#' @param raw Raw response body.
#' @return Character vector of log lines (status markers included as
#'   `[status] ...` when present).
#' @keywords internal
.od_parse_build_log_raw <- function(raw) {
  if (!length(raw)) {
    return(character())
  }
  pos <- 1L
  n <- length(raw)
  lines <- character()

  while (pos + 3L <= n) {
    len <- .od_read_i32be(raw, pos)
    pos <- pos + 4L
    if (len == 0L) {
      next
    }
    alen <- abs(as.integer(len))
    if (pos + alen - 1L > n) {
      break
    }
    chunk <- raw[pos:(pos + alen - 1L)]
    pos <- pos + alen

    if (len < 0L) {
      status <- rawToChar(chunk)
      lines <- c(lines, paste0("[status] ", status))
    } else {
      txt <- rawToChar(chunk)
      obj <- tryCatch(
        jsonlite::fromJSON(txt, simplifyVector = FALSE),
        error = function(e) NULL
      )
      if (is.null(obj)) {
        next
      }
      msgs <- obj$messages %||% list()
      parts <- vapply(
        msgs,
        function(m) as.character(m$text %||% "")[1],
        character(1)
      )
      line <- paste(parts[nzchar(parts)], collapse = "")
      if (nzchar(line)) {
        lines <- c(lines, line)
      }
    }
  }

  lines
}

#' Get build log lines
#'
#' Downloads `/~api/streaming/build-logs/{id}` and parses OneDev's binary log
#' stream into plain-text lines (same idea as `tod build get-log`).
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @param timeout Seconds to wait for the full log stream (default `60`).
#' @return Character vector of log lines.
#' @export
od_get_build_log <- function(
  build_number,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
) {
  conn <- .od_conn(conn)
  build_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
  raw <- .od_request_raw(
    method = "GET",
    endpoint = paste0("/streaming/build-logs/", build_id),
    conn = conn,
    accept = "*/*",
    timeout = timeout
  )
  .od_parse_build_log_raw(raw)
}
