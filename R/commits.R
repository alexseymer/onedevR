#' Set or update a commit status
#'
#' Sets the status of a commit (e.g., from a CI system) for visibility in the web UI.
#'
#' @param commit_hash Commit SHA.
#' @param state Status state (e.g., `"pending"`, `"success"`, `"failure"`, `"error"`).
#' @param context Context identifier for this status (e.g., `"continuous-integration/my-ci"`).
#' @param description Optional description of the status.
#' @param target_url Optional URL to the CI build/check details.
#' @param project Project path or numeric id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed commit status object (list).
#' @family repository
#' @examples
#' \dontrun{
#' od_set_commit_status(
#'   "abc123def456",
#'   state = "success",
#'   context = "ci/build"
#' )
#' }
#' @export
od_set_commit_status <- function(
  commit_hash,
  state,
  context,
  description = NULL,
  target_url = NULL,
  project = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  commit_hash <- .od_coerce_string(commit_hash)
  .od_require(commit_hash, "commit_hash")
  state <- .od_coerce_string(state)
  .od_require(state, "state")
  context <- .od_coerce_string(context)
  .od_require(context, "context")

  project_id <- od_resolve_project_id(project = project, conn = conn)

  body <- list(
    state = state,
    context = context
  )
  if (!is.null(description) && nzchar(as.character(description)[1])) {
    body$description <- as.character(description)[1]
  }
  if (!is.null(target_url) && nzchar(as.character(target_url)[1])) {
    body$targetUrl <- as.character(target_url)[1]
  }

  od_request(
    method = "POST",
    endpoint = paste0("/repositories/", project_id, "/commits/", commit_hash, "/statuses"),
    body = body,
    conn = conn
  )
}

#' Get commit statuses
#'
#' Retrieves all statuses set on a commit from various systems.
#'
#' @param commit_hash Commit SHA.
#' @param project Project path or numeric id; defaults to the connection project.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of commit statuses (default), or a list when `as_tibble = FALSE`.
#' @family repository
#' @examples
#' \dontrun{
#' od_get_commit_statuses("abc123def456")
#' }
#' @export
od_get_commit_statuses <- function(
  commit_hash,
  project = NULL,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  commit_hash <- .od_coerce_string(commit_hash)
  .od_require(commit_hash, "commit_hash")

  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    method = "GET",
    endpoint = paste0("/repositories/", project_id, "/commits/", commit_hash, "/statuses"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}
