#' Query OneDev issues
#'
#' @param query Raw OneDev issue query string (see `tod issue get-query-description`
#'   / OneDev query DSL). Example: `'"Number" is "group/project#145"'`.
#' @param state Optional state filter (e.g. `"Open"`). Combined with `query`
#'   via `and`. When both are empty, falls back to `conn$default_issue_state`
#'   (`ONEDEV_ISSUE_STATE`).
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#'
#' @return Parsed API response (list). Use the internal normalizer when you
#'   need a flat item list (handles `items` / `data` wrappers).
#' @export
od_query_issues <- function(query = NULL, state = NULL, count = 100L, offset = 0L, conn = NULL) {
  conn <- .od_conn(conn)
  query <- trimws(as.character(query %||% "")[1])
  state <- trimws(as.character(state %||% "")[1])

  if (!nzchar(query) && !nzchar(state)) {
    state <- conn$default_issue_state %||% ""
  }
  if (nzchar(state)) {
    state_clause <- paste0('State is "', state, '"')
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", state_clause)
    } else {
      state_clause
    }
  }

  od_request(
    method = "GET",
    endpoint = "/issues",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
}

#' Get a single issue by UI number
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `issue_number` as the internal REST
#'   id (debugging only).
#' @return Parsed issue object (list).
#' @export
od_get_issue <- function(issue_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  issue_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(issue_number)
  } else {
    od_resolve_issue_id(issue_number, conn = conn)
  }
  od_request("GET", paste0("/issues/", issue_id), conn = conn)
}

#' Get custom fields for an issue
#'
#' Calls `GET /issues/{id}/fields`. Field names and allowed values are
#' installation-specific (see `project_plan.md` §10).
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `issue_number` as the internal REST
#'   id (debugging only).
#' @return Named list (or map) of field name → value.
#' @export
od_get_issue_fields <- function(issue_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  issue_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(issue_number)
  } else {
    od_resolve_issue_id(issue_number, conn = conn)
  }
  od_request("GET", paste0("/issues/", issue_id, "/fields"), conn = conn)
}

#' Create a OneDev issue
#'
#' Tries both common create body shapes (`projectId` scalar and
#' `project = list(id = ...)`) via the internal request-variants helper.
#'
#' @param title Issue title.
#' @param description Issue description (Markdown).
#' @param fields Named list of custom fields (installation-specific).
#' @param iteration_ids Optional numeric iteration ids from
#'   [od_list_iterations()]; sent as `iterationIds` in the create body.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed created issue (list).
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
#' @param issue_number UI number.
#' @param title New title.
#' @param conn Connection list.
#' @return Parsed API response.
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
#' @param issue_number UI number.
#' @param description New description (Markdown).
#' @param conn Connection list.
#' @return Parsed API response.
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
#' @param issue_number UI number.
#' @param fields Named list of field values (installation-specific schema).
#' @param conn Connection list.
#' @return Parsed API response.
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
#' string) — see `project_plan.md` §10 and `tod issue change-state`.
#'
#' @param issue_number UI number.
#' @param state Target state name (e.g. `"Closed"`).
#' @param conn Connection list.
#' @return Parsed API response.
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
