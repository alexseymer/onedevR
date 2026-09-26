.onedevr_env <- new.env(parent = emptyenv())

#' Resolve the active OneDev connection
#'
#' Preference order: explicit `conn`, package default from
#' [od_set_connection()], then environment via [od_get_config()].
#'
#' @param conn Optional connection list.
#' @param validate Passed to [od_get_config()] when falling back to env.
#' @return A connection list.
#' @noRd
.od_conn <- function(conn = NULL, validate = TRUE) {
  conn %||% .onedevr_env$connection %||% od_get_config(validate = validate)
}

#' Infer auth mode from connection fields
#' @noRd
.od_infer_auth <- function(auth = NULL, username = "", token = "", password = "") {
  auth <- .od_coerce_string(auth)
  if (nzchar(auth)) {
    auth <- tolower(auth)
    if (!auth %in% c("bearer", "basic")) {
      stop("`auth` must be \"bearer\" or \"basic\".", call. = FALSE)
    }
    return(auth)
  }
  if (nzchar(username)) "basic" else "bearer"
}

#' Validate connection credentials for the chosen auth mode
#' @noRd
.od_validate_auth <- function(conn, context = "connection") {
  auth <- tolower(conn$auth %||% "bearer")
  if (identical(auth, "basic")) {
    if (!nzchar(conn$username %||% "")) {
      stop(paste0(context, ": Basic Auth requires `username`."), call. = FALSE)
    }
    if (!nzchar(conn$password %||% "") && !nzchar(conn$token %||% "")) {
      stop(
        paste0(context, ": Basic Auth requires `password` (or `token` as password)."),
        call. = FALSE
      )
    }
  } else if (!nzchar(conn$token %||% "")) {
    stop(paste0(context, ": Bearer auth requires `token`."), call. = FALSE)
  }
  invisible()
}

#' Build an explicit OneDev connection
#'
#' Prefer this over environment variables for scripts and multi-host workflows.
#' Pass the result as `conn =` to high-level helpers, or register it as the
#' package default with [od_set_connection()].
#'
#' Authentication is **Bearer** by default (`token`). For **Basic Auth**, set
#' `username` (and `password`, or reuse `token` as the password) - `auth` is
#' inferred as `"basic"` when `username` is non-empty, or set `auth = "basic"`
#' explicitly.
#'
#' @param host {character} OneDev base URL (e.g. `"https://git.example.test"`).
#' @param token {character} API access token (Bearer), or Basic Auth password when
#'   `auth = "basic"` and `password` is unset. Default: `NULL`.
#' @param username {character} Optional username for Basic Auth. Default: `NULL`.
#' @param password {character} Optional Basic Auth password (defaults to `token` when unset). Default: `NULL`.
#' @param auth {character} `"bearer"` or `"basic"`. Default: `"basic"` when `username` is
#'   set, otherwise `"bearer"`. Default: `NULL`.
#' @param project_path {character} Project path (e.g. `"group/my-project"`). Default: `NULL`.
#' @param project_id {character|numeric} Optional numeric project id (skips path resolution when set). Default: `NULL`.
#' @param repo_url {character} Optional git remote URL; used to derive `project_path` when
#'   that is unset. Default: `NULL`.
#' @param default_issue_state {character} Optional default for [od_query_issues()] when no
#'   query/state is given. Default: `NULL`.
#' @param insecure_ssl {logical} If `TRUE`, skip TLS certificate verification. Default: `FALSE`.
#' @param validate {logical} If `TRUE` (default), error when host/credentials are missing. Default: `TRUE`.
#'
#' @return {list} A named list with connection fields, classed as `od_connection`.
#'
#' @examples
#' \dontrun{
#' conn <- od_connection(
#'   host = "https://git.example.test",
#'   token = Sys.getenv("ONEDEV_API_TOKEN"),
#'   project_path = "group/my-project"
#' )
#' od_get_issue(145, conn = conn)
#'
#' basic <- od_connection(
#'   host = "https://git.example.test",
#'   username = "alice",
#'   password = "secret",
#'   project_path = "group/my-project"
#' )
#' }
#' @family connection
#' @export
od_connection <- function(
  host,
  token = NULL,
  username = NULL,
  password = NULL,
  auth = NULL,
  project_path = NULL,
  project_id = NULL,
  repo_url = NULL,
  default_issue_state = NULL,
  insecure_ssl = FALSE,
  validate = TRUE
) {
  host <- sub("/+$", "", .od_coerce_string(host))
  token <- .od_coerce_string(token)
  username <- .od_coerce_string(username)
  password <- .od_coerce_string(password)
  repo_url <- .od_coerce_string(repo_url)
  project_path <- .od_first_non_empty(
    project_path,
    .od_derive_project_path(repo_url)
  )
  project_id <- if (is.null(project_id) || !nzchar(as.character(project_id)[1])) {
    ""
  } else {
    .od_coerce_string(project_id)
  }
  default_issue_state <- .od_coerce_string(default_issue_state)
  auth_mode <- .od_infer_auth(auth, username, token, password)

  conn <- list(
    host = host,
    api_base_url = if (nzchar(host)) paste0(host, "/~api") else "",
    token = token,
    username = username,
    password = password,
    auth = auth_mode,
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
    .od_validate_auth(conn, context = "`od_connection()`")
  }

  conn
}

#' Set or clear the package-default OneDev connection
#'
#' After calling this, high-level `od_*` helpers that omit `conn` use the
#' registered connection instead of reading `ONEDEV_*` environment variables.
#' Pass `NULL` to clear the default.
#'
#' @param conn {list} An [od_connection()] (or compatible list), or `NULL` to unset.
#' @return {list} `conn`, invisibly.
#' @family connection
#' @examples
#' \dontrun{
#' od_set_connection(od_connection(host = "https://git.example.test", token = "t", project_path = "p"))
#' }
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
#' @return {list} The connection registered with [od_set_connection()], or `NULL`.
#' @family connection
#' @examples
#' \dontrun{
#' od_get_connection()
#' }
#' @export
od_get_connection <- function() {
  .onedevr_env$connection
}
