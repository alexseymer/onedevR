#' Query OneDev issues
#'
#' @param query {character} Raw OneDev issue query string (see `tod issue get-query-description`
#'   / OneDev query DSL). Example: `'"Number" is "group/project#145"'`. Default: `NULL`.
#' @param state {character} Optional state filter (e.g. `"Open"`). Combined with `query`
#'   via `and`. When both are empty, falls back to `conn$default_issue_state`
#'   (`ONEDEV_ISSUE_STATE`). Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`).
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]; if `FALSE`, the raw list payload / items. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {tibble|list} A tibble of issues (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /issues
#' @family issues
#' @examples
#' \dontrun{
#' od_query_issues(state = "Open", count = 20L)
#' }
#' @export
od_query_issues <- function(
  query = NULL,
  state = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- .od_coerce_string(query)
  state <- .od_coerce_string(state)

  if (!nzchar(query) && !nzchar(state)) {
    state <- conn$default_issue_state %||% ""
  }
  if (nzchar(state)) {
    state_clause <- paste0('"State" is "', state, '"')
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", state_clause)
    } else {
      state_clause
    }
  }

  payload <- od_request(
    method = "GET",
    endpoint = "/issues",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a single issue by UI number
#'
#' @param issue_number {character|numeric} UI number (`145` or `"#145"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `issue_number` as the internal REST
#'   id (debugging only). Default: `FALSE`.
#' @return {list} Parsed issue object.
#' @endpoint GET /issues/{issueId}
#' @family issues
#' @examples
#' \dontrun{
#' od_get_issue(145)
#' }
#' @export
od_get_issue <- function(issue_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  issue_id <- .od_resolve_entity_id(
    issue_number,
    od_resolve_issue_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/issues/", issue_id), conn = conn)
}

#' Get custom fields for an issue
#'
#' Calls `GET /issues/{id}/fields`. Field names and allowed values are
#' installation-specific (see `project_plan.md` sec 10).
#'
#' @param issue_number {character|numeric} UI number (`145` or `"#145"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `issue_number` as the internal REST
#'   id (debugging only). Default: `FALSE`.
#' @return {list} Named list (or map) of field name -> value.
#' @endpoint GET /issues/{issueId}/fields
#' @family issues
#' @examples
#' \dontrun{
#' od_get_issue_fields(145)
#' }
#' @export
od_get_issue_fields <- function(issue_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  issue_id <- .od_resolve_entity_id(
    issue_number,
    od_resolve_issue_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/issues/", issue_id, "/fields"), conn = conn)
}

#' Create a OneDev issue
#'
#' Tries both common create body shapes (`projectId` scalar and
#' `project = list(id = ...)`) via the internal request-variants helper.
#'
#' @param title {character} Issue title.
#' @param description {character} Issue description (Markdown). Default: `""`.
#' @param fields {list} Named list of custom fields (installation-specific). Default: `list()`.
#' @param iteration_ids {numeric} Optional numeric iteration ids from
#'   [od_list_iterations()]; sent as `iterationIds` in the create body. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed created issue.
#' @endpoint POST /issues
#' @family issues
#' @examples
#' \dontrun{
#' od_create_issue(title = "API test", description = "From R")
#' }
#' @export
od_create_issue <- function(
  title,
  description = "",
  fields = list(),
  iteration_ids = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  project_id <- as.integer(od_resolve_project_id(conn = conn))
  title <- as.character(title)[1]
  description <- as.character(description %||% "")[1]

  base_a <- list(
    projectId = project_id,
    title = title,
    description = description
  )
  base_b <- list(
    project = list(id = project_id),
    title = title,
    description = description
  )
  if (length(fields) > 0) {
    base_a$fields <- fields
    base_b$fields <- fields
  }
  if (!is.null(iteration_ids) && length(iteration_ids) > 0) {
    ids <- as.list(as.integer(iteration_ids))
    base_a$iterationIds <- ids
    base_b$iterationIds <- ids
  }

  .od_request_with_variants(
    method = "POST",
    endpoint = "/issues",
    body_variants = list(base_a, base_b),
    conn = conn
  )
}

#' Set an issue title
#'
#' @param issue_number {character|numeric} UI number.
#' @param title {character} New title.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response.
#' @endpoint POST /issues/{issueId}/title
#' @family issues
#' @examples
#' \dontrun{
#' od_issue_set_title(145, "New title")
#' }
#' @export
od_issue_set_title <- function(issue_number, title, conn = NULL) {
  conn <- .od_conn(conn)
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)
  .od_request_with_variants(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/title"),
    body_variants = list(
      list(title = as.character(title)[1]),
      as.character(title)[1]
    ),
    conn = conn
  )
}

#' Set an issue description
#'
#' @param issue_number {character|numeric} UI number.
#' @param description {character} New description (Markdown).
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response.
#' @endpoint POST /issues/{issueId}/description
#' @family issues
#' @examples
#' \dontrun{
#' od_issue_set_description(145, "Updated body")
#' }
#' @export
od_issue_set_description <- function(issue_number, description, conn = NULL) {
  conn <- .od_conn(conn)
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)
  .od_request_with_variants(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/description"),
    body_variants = list(
      list(description = as.character(description)[1]),
      as.character(description)[1]
    ),
    conn = conn
  )
}

#' Set custom issue fields
#'
#' @param issue_number {character|numeric} UI number.
#' @param fields {list} Named list of field values (installation-specific schema).
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response.
#' @endpoint POST /issues/{issueId}/fields
#' @family issues
#' @examples
#' \dontrun{
#' od_issue_set_fields(145, list(Priority = "Normal"))
#' }
#' @export
od_issue_set_fields <- function(issue_number, fields, conn = NULL) {
  conn <- .od_conn(conn)
  if (!is.list(fields) || is.null(names(fields)) || any(!nzchar(names(fields)))) {
    stop("`fields` must be a named list.", call. = FALSE)
  }
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)
  od_request(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/fields"),
    body = fields,
    conn = conn
  )
}

#' Transition an issue to a new state
#'
#' Tries the known body shapes (`list(state=)`, `list(transition=)`, raw
#' string) - see `project_plan.md` sec 10 and `tod issue change-state`.
#'
#' @param issue_number {character|numeric} UI number.
#' @param state {character} Target state name (e.g. `"Closed"`).
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response.
#' @family issues
#' @examples
#' \dontrun{
#' od_issue_transition_state(145, "Closed")
#' }
#' @export
od_issue_transition_state <- function(issue_number, state, conn = NULL) {
  conn <- .od_conn(conn)
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)
  state <- as.character(state)[1]
  .od_request_with_variants(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/state-transitions"),
    body_variants = list(
      list(state = state),
      list(transition = state),
      state
    ),
    conn = conn
  )
}

#' Get comments on an issue
#'
#' @param issue_number {character|numeric} UI number (`145` or `"#145"`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `issue_number` as the internal REST id. Default: `FALSE`.
#' @return {tibble|list} A tibble of comments (default), or a list when `as_tibble = FALSE`.
#' @family issues
#' @examples
#' \dontrun{
#' od_get_issue_comments(145)
#' }
#' @export
od_get_issue_comments <- function(
  issue_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  issue_id <- .od_resolve_entity_id(
    issue_number,
    od_resolve_issue_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  payload <- od_request("GET", paste0("/issues/", issue_id, "/comments"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Add a comment to an issue
#'
#' Posts to `POST /issue-comments` with `issueId` + `content`.
#'
#' @param issue_number {character|numeric} UI number (`145` or `"#145"`).
#' @param content {character} Comment body (Markdown).
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {list} Parsed API response.
#' @family issues
#' @examples
#' \dontrun{
#' od_add_issue_comment(145, "Looks good")
#' }
#' @export
od_add_issue_comment <- function(issue_number, content, conn = NULL) {
  conn <- .od_conn(conn)
  issue_id <- as.integer(od_resolve_issue_id(issue_number, conn = conn))
  od_request(
    method = "POST",
    endpoint = "/issue-comments",
    body = list(
      issueId = issue_id,
      content = as.character(content)[1]
    ),
    conn = conn
  )
}

#' Link an issue to a pull request
#'
#' Creates a link between an issue and a pull request, indicating the PR is
#' related to or closes the issue.
#'
#' @param issue_number {character|numeric} UI issue number (`145` or `"#145"`).
#' @param pull_request_number {character|numeric} UI pull request number (`42` or `"#42"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response.
#' @family issues
#' @examples
#' \dontrun{
#' od_link_issue_to_pull_request(145, 42)
#' }
#' @export
od_link_issue_to_pull_request <- function(
  issue_number,
  pull_request_number,
  conn = NULL
) {
  conn <- .od_conn(conn)
  issue_id <- as.integer(od_resolve_issue_id(issue_number, conn = conn))
  pr_id <- as.integer(od_resolve_pull_request_id(pull_request_number, conn = conn))
  od_request(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/pull-requests"),
    body = list(pullRequestId = pr_id),
    conn = conn
  )
}

#' Get pull requests linked to an issue
#'
#' Retrieves all pull requests that are linked to a specific issue.
#'
#' @param issue_number {character|numeric} UI issue number (`145` or `"#145"`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @param use_internal_id {logical} If `TRUE`, treat `issue_number` as the internal REST id. Default: `FALSE`.
#' @return {tibble|list} A tibble of linked pull requests (default), or a list when `as_tibble = FALSE`.
#' @family issues
#' @examples
#' \dontrun{
#' od_get_issue_pull_requests(145)
#' }
#' @export
od_get_issue_pull_requests <- function(
  issue_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  issue_id <- .od_resolve_entity_id(
    issue_number,
    od_resolve_issue_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  payload <- od_request(
    "GET",
    paste0("/issues/", issue_id, "/pull-requests"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Remove a link between an issue and a pull request
#'
#' Removes the link between an issue and a pull request.
#'
#' @param issue_number {character|numeric} UI issue number (`145` or `"#145"`).
#' @param pull_request_number {character|numeric} UI pull request number (`42` or `"#42"`).
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response.
#' @family issues
#' @examples
#' \dontrun{
#' od_unlink_issue_from_pull_request(145, 42)
#' }
#' @export
od_unlink_issue_from_pull_request <- function(
  issue_number,
  pull_request_number,
  conn = NULL
) {
  conn <- .od_conn(conn)
  issue_id <- as.integer(od_resolve_issue_id(issue_number, conn = conn))
  pr_id <- as.integer(od_resolve_pull_request_id(pull_request_number, conn = conn))
  od_request(
    method = "DELETE",
    endpoint = paste0("/issues/", issue_id, "/pull-requests/", pr_id),
    conn = conn
  )
}
