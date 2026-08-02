#' Query OneDev packages
#'
#' Calls `GET /packages`.
#'
#' @param query Optional package query string (e.g.
#'   `'"Type" is "Container Image"'`).
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of packages (default), or a list when `as_tibble = FALSE`.
#' @family packages
#' @examples
#' \dontrun{
#' od_query_packages(count = 20L)
#' }
#' @export
od_query_packages <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- trimws(as.character(query %||% "")[1])
  payload <- od_request(
    method = "GET",
    endpoint = "/packages",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a package by id
#'
#' @param pack_id Package id.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed package object (list).
#' @family packages
#' @examples
#' \dontrun{
#' od_get_pack(1)
#' }
#' @export
od_get_pack <- function(pack_id, conn = NULL) {
  conn <- .od_conn(conn)
  pack_id <- trimws(as.character(pack_id %||% "")[1])
  if (!nzchar(pack_id)) {
    stop("`pack_id` is required.", call. = FALSE)
  }
  od_request("GET", paste0("/packages/", pack_id), conn = conn)
}

#' Get blobs for a package
#'
#' @param pack_id Package id.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of blobs (default), or a list when `as_tibble = FALSE`.
#' @family packages
#' @examples
#' \dontrun{
#' od_get_pack_blobs(1)
#' }
#' @export
od_get_pack_blobs <- function(pack_id, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  pack_id <- trimws(as.character(pack_id %||% "")[1])
  if (!nzchar(pack_id)) {
    stop("`pack_id` is required.", call. = FALSE)
  }
  payload <- od_request("GET", paste0("/packages/", pack_id, "/blobs"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get labels for a package
#'
#' @param pack_id Package id.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of labels (default), or a list when `as_tibble = FALSE`.
#' @family packages
#' @examples
#' \dontrun{
#' od_get_pack_labels(1)
#' }
#' @export
od_get_pack_labels <- function(pack_id, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  pack_id <- trimws(as.character(pack_id %||% "")[1])
  if (!nzchar(pack_id)) {
    stop("`pack_id` is required.", call. = FALSE)
  }
  payload <- od_request("GET", paste0("/packages/", pack_id, "/labels"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}
