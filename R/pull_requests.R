#' Query OneDev pull requests
#'
#' Not limited to the connection project: this returns the matching pull requests
#' of the whole instance. To scope it to one project, add
#' `'"Target Project" is "group/name"'` (or `"Source Project"`) to `query`. The
#' field `"Project"` is rejected with HTTP 500 for pull requests (verified live).
#'
#' @param query {character} Raw OneDev pull-request query string (see
#'   [od_get_query_description()] with `kind = "pull_request"`). Default: `NULL`.
#' @param status {character} Optional status keyword: `"open"`, `"merged"`, or `"discarded"`
#'   (case-insensitive). Combined with `query` via `and`. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`). OneDev returns at most 100 per request; larger values are fetched in several requests.
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {tibble|list} A tibble of pull requests (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /pulls
#' @family pull requests
#' @examples
#' \dontrun{
#' od_query_pull_requests(status = "open", count = 10L)
#' }
#' @export
od_query_pull_requests <- function(
  query = NULL,
  status = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- .od_coerce_string(query)
  status <- tolower(.od_coerce_string(status))

  if (nzchar(status)) {
    if (!status %in% c("open", "merged", "discarded")) {
      stop(
        '`status` must be one of "open", "merged", or "discarded".',
        call. = FALSE
      )
    }
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", status)
    } else {
      status
    }
  }

  payload <- .od_get_list(
    "/pulls",
    query = if (nzchar(query)) query else NULL,
    count = count,
    offset = offset,
    conn = conn,
    request = od_request
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a single pull request by UI number
#'
#' @param pull_request_number {character|numeric} UI number (`42` or `"#42"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `pull_request_number` as the
#'   internal REST id (debugging only). Default: `FALSE`.
#' @return {list} Parsed pull request object.
#' @endpoint GET /pulls/{pullRequestId}
#' @family pull requests
#' @examples
#' \dontrun{
#' od_get_pull_request(1)
#' }
#' @export
od_get_pull_request <- function(
  pull_request_number,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- .od_resolve_entity_id(
    pull_request_number,
    od_resolve_pull_request_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/pulls/", request_id), conn = conn)
}

#' Get comments on a pull request
#'
#' @param pull_request_number {character|numeric} UI number (`42` or `"#42"`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `pull_request_number` as the
#'   internal REST id. Default: `FALSE`.
#' @return {tibble|list} A tibble of comments (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /pulls/{pullRequestId}/comments
#' @family pull requests
#' @examples
#' \dontrun{
#' od_get_pull_request_comments(1)
#' }
#' @export
od_get_pull_request_comments <- function(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- .od_resolve_entity_id(
    pull_request_number,
    od_resolve_pull_request_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  payload <- od_request("GET", paste0("/pulls/", request_id, "/comments"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get reviews on a pull request
#'
#' @param pull_request_number {character|numeric} UI number (`42` or `"#42"`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `pull_request_number` as the
#'   internal REST id. Default: `FALSE`.
#' @return {tibble|list} A tibble of reviews (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /pulls/{pullRequestId}/reviews
#' @family pull requests
#' @examples
#' \dontrun{
#' od_get_pull_request_reviews(1)
#' }
#' @export
od_get_pull_request_reviews <- function(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  request_id <- .od_resolve_entity_id(
    pull_request_number,
    od_resolve_pull_request_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  payload <- od_request("GET", paste0("/pulls/", request_id, "/reviews"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Create a pull request
#'
#' @param title {character} PR title.
#' @param source_branch {character} Source branch name.
#' @param target_branch {character} Target branch name (default `"main"`). Default: `"main"`.
#' @param description {character} Optional Markdown description. Default: `""`.
#' @param source_project {character} Optional source project path/id; defaults to the
#'   connection project. Default: `NULL`.
#' @param target_project {character} Optional target project path/id; defaults to
#'   `source_project`. Default: `NULL`.
#' @param reviewer_ids {numeric} Optional numeric user ids. Default: `NULL`.
#' @param assignee_ids {numeric} Optional numeric user ids. Default: `NULL`.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed created PR, or `NULL` if the server returns an empty body.
#' @endpoint POST /pulls
#' @family pull requests
#' @examples
#' \dontrun{
#' od_create_pull_request("Title", source_branch = "feature", target_branch = "main")
#' }
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
#' Posts to `POST /pull-request-comments` with `requestId`, `content` and
#' `userId`. Without an author OneDev answers HTTP 500 (verified live, as for
#' issue comments), so the current user is sent by default.
#'
#' @param pull_request_number {character|numeric} UI number.
#' @param content {character} Comment body (Markdown).
#' @param conn {list} Connection list. Default: `NULL`.
#' @param user {character|numeric} Optional author: login name or numeric user
#'   id, sent as `userId`. Default: `NULL`, which uses the current user. If the
#'   current user cannot be determined, no `userId` is sent. A `user` that is
#'   given but cannot be resolved is an error.
#' @return {list} Parsed API response.
#' @endpoint POST /pull-request-comments
#' @family pull requests
#' @examples
#' \dontrun{
#' od_add_pull_request_comment(1, "LGTM")
#' }
#' @export
od_add_pull_request_comment <- function(pull_request_number, content, conn = NULL, user = NULL) {
  conn <- .od_conn(conn)
  request_id <- as.integer(od_resolve_pull_request_id(pull_request_number, conn = conn))
  body <- list(
    requestId = request_id,
    content = as.character(content)[1]
  )
  user_id <- .od_comment_user_id(user, conn, get_me = od_get_me, whoami = od_whoami, resolve = od_resolve_user_id)
  if (!is.null(user_id) && nzchar(as.character(user_id)[1])) {
    body$userId <- as.integer(user_id)
  }
  od_request(
    method = "POST",
    endpoint = "/pull-request-comments",
    body = body,
    conn = conn
  )
}

#' Approve a pull request
#'
#' @param pull_request_number {character|numeric} UI number.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response (may be `NULL`).
#' @endpoint POST /pulls/{pullRequestId}/approve
#' @family pull requests
#' @examples
#' \dontrun{
#' od_approve_pull_request(1)
#' }
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
#' @param pull_request_number {character|numeric} UI number.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response (may be `NULL`).
#' @endpoint POST /pulls/{pullRequestId}/request-for-changes
#' @family pull requests
#' @examples
#' \dontrun{
#' od_request_pull_request_changes(1)
#' }
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
#' HTTP 406 with a merge-conflicts message means the source branch has diverged
#' from the target: rebase (or merge) the source onto the target and retry.
#' That response is expected server behavior, not a client bug.
#'
#' @param pull_request_number {character|numeric} UI number.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response (may be `NULL`).
#' @endpoint POST /pulls/{pullRequestId}/merge
#' @family pull requests
#' @examples
#' \dontrun{
#' od_merge_pull_request(1)
#' }
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
#' @param pull_request_number {character|numeric} UI number.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response (may be `NULL`).
#' @endpoint POST /pulls/{pullRequestId}/discard
#' @family pull requests
#' @examples
#' \dontrun{
#' od_discard_pull_request(1)
#' }
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

#' Get the issues a pull request fixes
#'
#' Calls `GET /pulls/{requestId}/fixed-issue-ids`: the ids of the issues that
#' the pull request fixes (for example through `fixes #12` in a commit message).
#' The result holds internal issue ids, not UI numbers; use
#' `od_get_issue(id, use_internal_id = TRUE)` for details.
#'
#' @param pull_request_number {character|numeric} UI pull request number (`42` or `"#42"`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble with the column `id`. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `pull_request_number` as the internal REST id. Default: `FALSE`.
#' @return {tibble|list} A tibble with the column `id` (default), or a list of ids when `as_tibble = FALSE`.
#' @endpoint GET /pulls/{requestId}/fixed-issue-ids
#' @family pull requests
#' @examples
#' \dontrun{
#' od_get_pull_request_issues(42)
#' }
#' @export
od_get_pull_request_issues <- function(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  pr_id <- .od_resolve_entity_id(
    pull_request_number,
    od_resolve_pull_request_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  payload <- od_request(
    "GET",
    paste0("/pulls/", pr_id, "/fixed-issue-ids"),
    conn = conn
  )
  ids <- as.list(as.integer(unlist(payload, use.names = FALSE)))
  if (!.od_as_tibble_default(as_tibble)) {
    return(ids)
  }
  tibble::tibble(id = as.integer(unlist(ids, use.names = FALSE)))
}
