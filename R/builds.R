#' Map a build status filter to OneDev query DSL
#'
#' OneDev build queries use keyword criteria (`successful`, `failed`, ...), not
#' a `"Status" is "..."` field. Accepts those keywords or common enum spellings
#' (`SUCCESSFUL`, `FAILED`, `TIMED_OUT`, ...).
#' @noRd
.od_build_status_clause <- function(status) {
  status <- .od_coerce_string(status)
  if (!nzchar(status)) {
    return("")
  }
  key <- tolower(gsub("[_-]+", " ", status))
  key <- gsub("\\s+", " ", key)
  aliases <- c(
    "successful" = "successful",
    "success" = "successful",
    "succeeded" = "successful",
    "failed" = "failed",
    "failure" = "failed",
    "cancelled" = "cancelled",
    "canceled" = "cancelled",
    "timed out" = "timed out",
    "timeout" = "timed out",
    "finished" = "finished",
    "running" = "running",
    "waiting" = "waiting",
    "pending" = "pending"
  )
  clause <- unname(aliases[key])
  if (is.na(clause) || !nzchar(clause)) {
    stop(
      paste0(
        "Unknown build status '", status, "'. ",
        "Use a OneDev keyword: successful, failed, cancelled, timed out, ",
        "finished, running, waiting, pending ",
        "(or enum-like SUCCESSFUL / FAILED / ...)."
      ),
      call. = FALSE
    )
  }
  clause
}

#' Query OneDev builds
#'
#' @param query {character} Raw OneDev build query string (see [od_get_query_description()]
#'   with `kind = "build"`, or `tod build get-query-description`). Example:
#'   `'"Number" is "group/project#100"'`. Default: `NULL`.
#' @param status {character} Optional status filter. OneDev uses keyword criteria - pass
#'   `"successful"`, `"failed"`, `"cancelled"`, `"timed out"`, `"finished"`,
#'   `"running"`, `"waiting"`, or `"pending"` (enum spellings like
#'   `"SUCCESSFUL"` are accepted and mapped). Combined with `query` via `and`. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`).
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {tibble|list} A tibble of builds (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /builds
#' @family builds
#' @examples
#' \dontrun{
#' od_query_builds(status = "successful", count = 10L)
#' }
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
  query <- .od_coerce_string(query)
  status_clause <- .od_build_status_clause(status)

  if (nzchar(status_clause)) {
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
#' @param build_number {character|numeric} UI number (`100` or `"#100"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `build_number` as the internal REST
#'   id (debugging only). Default: `FALSE`.
#' @return {list} Parsed build object.
#' @family builds
#' @examples
#' \dontrun{
#' od_get_build(100)
#' }
#' @export
od_get_build <- function(build_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  build_id <- .od_resolve_entity_id(
    build_number,
    od_resolve_build_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/builds/", build_id), conn = conn)
}

#' Get parameters for a build
#'
#' @param build_number {character|numeric} UI number (`100` or `"#100"`).
#' @param conn {list} Connection list. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `build_number` as the internal REST id. Default: `FALSE`.
#' @return {list} Parsed params payload.
#' @family builds
#' @examples
#' \dontrun{
#' od_get_build_params(100)
#' }
#' @export
od_get_build_params <- function(build_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  build_id <- .od_resolve_entity_id(
    build_number,
    od_resolve_build_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/builds/", build_id, "/params"), conn = conn)
}

#' Read a signed big-endian 32-bit integer from raw bytes
#' @noRd
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
#' @param raw {raw} Raw response body.
#' @return {character} Character vector of log lines (status markers included as
#'   `[status] ...` when present).
#' @noRd
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
#' @param build_number {character|numeric} UI number (`100` or `"#100"`).
#' @param conn {list} Connection list. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `build_number` as the internal REST id. Default: `FALSE`.
#' @param timeout {numeric} Seconds to wait for the full log stream (default `60`). Default: `60`.
#' @return {character} Character vector of log lines.
#' @family builds
#' @examples
#' \dontrun{
#' od_get_build_log(100)
#' }
#' @export
od_get_build_log <- function(
  build_number,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
) {
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
  .od_parse_build_log_raw(raw)
}

#' Promote a build to a new status/environment
#'
#' Transitions a build to a new promotion status (e.g., "staging", "production").
#'
#' @param build_number UI build number (`100` or `"#100"`).
#' @param status Target promotion status name (e.g., `"staging"`, `"production"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return Parsed API response.
#' @family builds
#' @examples
#' \dontrun{
#' od_promote_build(100, status = "production")
#' }
#' @export
od_promote_build <- function(
  build_number,
  status,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  build_id <- .od_resolve_entity_id(
    build_number,
    od_resolve_build_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  status <- .od_coerce_string(status)
  .od_require(status, "status")

  od_request(
    method = "POST",
    endpoint = paste0("/builds/", build_id, "/promotions"),
    body = list(status = status),
    conn = conn
  )
}
