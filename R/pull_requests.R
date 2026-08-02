#' Query OneDev pull requests
#'
#' @param query Raw OneDev pull-request query string (see
#'   `tod pr get-query-description` / OneDev query DSL).
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#'
#' @return Parsed API response (list).
#' @export
od_query_pull_requests <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- trimws(as.character(query %||% "")[1])

  od_request(
    method = "GET",
    endpoint = "/pulls",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
}

#' Get a single pull request by UI number
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `pull_request_number` as the
#'   internal REST id (debugging only).
#' @return Parsed pull request object (list).
#' @export
od_get_pull_request <- function(
  pull_request_number,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(pull_request_number)
  } else {
    od_resolve_pull_request_id(pull_request_number, conn = conn)
  }
  od_request("GET", paste0("/pulls/", request_id), conn = conn)
}

#' Get comments on a pull request
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `pull_request_number` as the
#'   internal REST id.
#' @return Parsed comments payload (list).
#' @export
od_get_pull_request_comments <- function(
  pull_request_number,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(pull_request_number)
  } else {
    od_resolve_pull_request_id(pull_request_number, conn = conn)
  }
  od_request("GET", paste0("/pulls/", request_id, "/comments"), conn = conn)
}

#' Get reviews on a pull request
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `pull_request_number` as the
#'   internal REST id.
#' @return Parsed reviews payload (list).
#' @export
od_get_pull_request_reviews <- function(
  pull_request_number,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(pull_request_number)
  } else {
    od_resolve_pull_request_id(pull_request_number, conn = conn)
  }
  od_request("GET", paste0("/pulls/", request_id, "/reviews"), conn = conn)
}
