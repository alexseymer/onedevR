.onedevr_env <- new.env(parent = emptyenv())

#' Resolve the active OneDev connection
#'
#' Preference order: explicit `conn`, package default from
#' [od_set_connection()], then environment via [od_get_config()].
#'
#' @param conn Optional connection list.
#' @param validate Passed to [od_get_config()] when falling back to env.
#' @return A connection list.
#' @keywords internal
.od_conn <- function(conn = NULL, validate = TRUE) {
  conn %||% .onedevr_env$connection %||% od_get_config(validate = validate)
}

#' Build an explicit OneDev connection
#'
#' Prefer this over environment variables for scripts and multi-host workflows.
#' Pass the result as `conn =` to high-level helpers, or register it as the
#' package default with [od_set_connection()].
#'
#' @param host OneDev base URL (e.g. `"https://git.example.test"`).
#' @param token API access token (Bearer).
#' @param project_path Project path (e.g. `"group/my-project"`).
#' @param project_id Optional numeric project id (skips path resolution when set).
#' @param repo_url Optional git remote URL; used to derive `project_path` when
#'   that is unset.
#' @param default_issue_state Optional default for [od_query_issues()] when no
#'   query/state is given.
#' @param insecure_ssl If `TRUE`, skip TLS certificate verification.
#' @param validate If `TRUE` (default), error when `host` or `token` are empty.
#'
#' @return A named list with the same fields as [od_get_config()], classed as
#'   `od_connection`.
#'
#' @examples
#' \dontrun{
#' conn <- od_connection(
#'   host = "https://git.example.test",
#'   token = Sys.getenv("ONEDEV_API_TOKEN"),
#'   project_path = "group/my-project"
#' )
#' od_get_issue(145, conn = conn)
#' }
#' @export
od_connection <- function(
  host,
  token,
  project_path = NULL,
  project_id = NULL,
  repo_url = NULL,
  default_issue_state = NULL,
  insecure_ssl = FALSE,
  validate = TRUE
) {
  host <- sub("/+$", "", trimws(as.character(host %||% "")[1]))
  token <- trimws(as.character(token %||% "")[1])
  repo_url <- trimws(as.character(repo_url %||% "")[1])
  project_path <- .od_first_non_empty(
    project_path,
    .od_derive_project_path(repo_url)
  )
  project_id <- if (is.null(project_id) || !nzchar(as.character(project_id)[1])) {
    ""
  } else {
    trimws(as.character(project_id)[1])
  }
  default_issue_state <- trimws(as.character(default_issue_state %||% "")[1])

  conn <- list(
    host = host,
    api_base_url = if (nzchar(host)) paste0(host, "/~api") else "",
    token = token,
    repo_url = repo_url,
    project_id = project_id,
    project_path = project_path,
    default_issue_state = default_issue_state,
    insecure_ssl = isTRUE(insecure_ssl)
  )
  class(conn) <- c("od_connection", "list")

  if (isTRUE(validate)) {
    if (!nzchar(conn$host)) {
      stop("`host` is missing or empty.", call. = FALSE)
    }
    if (!nzchar(conn$token)) {
      stop("`token` is missing or empty.", call. = FALSE)
    }
  }

  conn
}

#' Set or clear the package-default OneDev connection
#'
#' After calling this, high-level `od_*` helpers that omit `conn` use the
#' registered connection instead of reading `ONEDEV_*` environment variables.
#' Pass `NULL` to clear the default.
#'
#' @param conn An [od_connection()] (or compatible list), or `NULL` to unset.
#' @return `conn`, invisibly.
#' @export
od_set_connection <- function(conn) {
  if (!is.null(conn) && !is.list(conn)) {
    stop("`conn` must be a connection list or NULL.", call. = FALSE)
  }
  .onedevr_env$connection <- conn
  invisible(conn)
}

#' Get the package-default OneDev connection
#'
#' @return The connection registered with [od_set_connection()], or `NULL`.
#' @export
od_get_connection <- function() {
  .onedevr_env$connection
}
