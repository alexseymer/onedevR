#' Query OneDev builds
#'
#' @param query Raw OneDev build query string (see `tod build get-query-description`
#'   / OneDev query DSL). Example: `'"Number" is "group/project#100"'`.
#' @param status Optional status filter (e.g. `"SUCCESSFUL"`, `"FAILED"`).
#'   Combined with `query` via `and`.
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#'
#' @return Parsed API response (list).
#' @export
od_query_builds <- function(
  query = NULL,
  status = NULL,
  count = 100L,
  offset = 0L,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- trimws(as.character(query %||% "")[1])
  status <- trimws(as.character(status %||% "")[1])

  if (nzchar(status)) {
    status_clause <- paste0('Status is "', status, '"')
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", status_clause)
    } else {
      status_clause
    }
  }

  od_request(
    method = "GET",
    endpoint = "/builds",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
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
