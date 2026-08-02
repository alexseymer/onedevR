#' Query OneDev pull requests
#'
#' @param query Raw OneDev pull-request query string (see
#'   `tod pr get-query-description` / OneDev query DSL).
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#'
#' @return A tibble of pull requests (default), or a list when `as_tibble = FALSE`.
#' @export
od_query_pull_requests <- function(
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
    endpoint = "/pulls",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
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
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `pull_request_number` as the
#'   internal REST id.
#' @return A tibble of comments (default), or a list when `as_tibble = FALSE`.
#' @export
od_get_pull_request_comments <- function(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(pull_request_number)
  } else {
    od_resolve_pull_request_id(pull_request_number, conn = conn)
  }
  payload <- od_request("GET", paste0("/pulls/", request_id, "/comments"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get reviews on a pull request
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `pull_request_number` as the
#'   internal REST id.
#' @return A tibble of reviews (default), or a list when `as_tibble = FALSE`.
#' @export
od_get_pull_request_reviews <- function(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(pull_request_number)
  } else {
    od_resolve_pull_request_id(pull_request_number, conn = conn)
  }
  payload <- od_request("GET", paste0("/pulls/", request_id, "/reviews"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Create a pull request
#'
#' @param title PR title.
#' @param source_branch Source branch name.
#' @param target_branch Target branch name (default `"main"`).
#' @param description Optional Markdown description.
#' @param source_project Optional source project path/id; defaults to the
#'   connection project.
#' @param target_project Optional target project path/id; defaults to
#'   `source_project`.
#' @param reviewer_ids Optional numeric user ids.
#' @param assignee_ids Optional numeric user ids.
#' @param conn Connection list.
#' @return Parsed created PR (list), or `NULL` if the server returns an empty body.
#' @export
od_create_pull_request <- function(
  title,
  source_branch,
  target_branch = "main",
  description = "",
  source_project = NULL,
  target_project = NULL,
  reviewer_ids = NULL,
  assignee_ids = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  source_project_id <- as.integer(
    od_resolve_project_id(project = source_project, conn = conn)
  )
  target_project_id <- if (is.null(target_project)) {
    source_project_id
  } else {
    as.integer(od_resolve_project_id(project = target_project, conn = conn))
  }

  body <- list(
    targetProjectId = target_project_id,
    sourceProjectId = source_project_id,
    targetBranch = as.character(target_branch)[1],
    sourceBranch = as.character(source_branch)[1],
    title = as.character(title)[1],
    description = as.character(description %||% "")[1]
  )
  if (!is.null(reviewer_ids) && length(reviewer_ids) > 0) {
    body$reviewerIds <- as.list(as.integer(reviewer_ids))
  }
  if (!is.null(assignee_ids) && length(assignee_ids) > 0) {
    body$assigneeIds <- as.list(as.integer(assignee_ids))
  }

  od_request(method = "POST", endpoint = "/pulls", body = body, conn = conn)
}

#' Add a comment to a pull request
#'
#' Posts to `POST /pull-request-comments` with `requestId` + `content`.
#'
#' @param pull_request_number UI number.
#' @param content Comment body (Markdown).
#' @param conn Connection list.
#' @return Parsed API response.
#' @export
od_add_pull_request_comment <- function(pull_request_number, content, conn = NULL) {
  conn <- .od_conn(conn)
  request_id <- as.integer(od_resolve_pull_request_id(pull_request_number, conn = conn))
  od_request(
    method = "POST",
    endpoint = "/pull-request-comments",
    body = list(
      requestId = request_id,
      content = as.character(content)[1]
    ),
    conn = conn
  )
}

#' Approve a pull request
#'
#' @param pull_request_number UI number.
#' @param conn Connection list.
#' @return Parsed API response (may be `NULL`).
#' @export
od_approve_pull_request <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  request_id <- od_resolve_pull_request_id(pull_request_number, conn = conn)
  od_request(
    method = "POST",
    endpoint = paste0("/pulls/", request_id, "/approve"),
    conn = conn
  )
}

#' Request changes on a pull request
#'
#' @param pull_request_number UI number.
#' @param conn Connection list.
#' @return Parsed API response (may be `NULL`).
#' @export
od_request_pull_request_changes <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  request_id <- od_resolve_pull_request_id(pull_request_number, conn = conn)
  od_request(
    method = "POST",
    endpoint = paste0("/pulls/", request_id, "/request-for-changes"),
    conn = conn
  )
}

#' Merge a pull request
#'
#' @param pull_request_number UI number.
#' @param conn Connection list.
#' @return Parsed API response (may be `NULL`).
#' @export
od_merge_pull_request <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  request_id <- od_resolve_pull_request_id(pull_request_number, conn = conn)
  od_request(
    method = "POST",
    endpoint = paste0("/pulls/", request_id, "/merge"),
    conn = conn
  )
}

#' Discard a pull request
#'
#' @param pull_request_number UI number.
#' @param conn Connection list.
#' @return Parsed API response (may be `NULL`).
#' @export
od_discard_pull_request <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  request_id <- od_resolve_pull_request_id(pull_request_number, conn = conn)
  od_request(
    method = "POST",
    endpoint = paste0("/pulls/", request_id, "/discard"),
    conn = conn
  )
}
