#' Default commit fields requested from repository endpoints
#' @keywords internal
.od_default_commit_fields <- function() {
  c("PARENTS", "AUTHOR", "COMMITTER", "COMMIT_DATE", "SUBJECT", "BODY")
}

#' Encode path segments for repository file/directory URLs
#' @keywords internal
.od_repo_path_encode <- function(parts) {
  parts <- as.character(unlist(parts, use.names = FALSE))
  parts <- parts[nzchar(parts)]
  paste(
    vapply(parts, utils::URLencode, character(1), reserved = TRUE),
    collapse = "/"
  )
}

#' Attach repeated `field` query params for commit endpoints
#' @keywords internal
.od_repo_commit_query <- function(query = NULL, count = NULL, fields = NULL) {
  q <- list()
  if (!is.null(query) && nzchar(as.character(query)[1])) {
    q$query <- as.character(query)[1]
  }
  if (!is.null(count)) {
    q$count <- as.integer(count)
  }
  fields <- as.character(fields %||% character())
  fields <- fields[nzchar(fields)]
  if (length(fields)) {
    # httr2 expands a character vector into repeated query keys
    q$field <- fields
  }
  q
}

#' List branches in a project
#'
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character vector of branch names.
#' @export
od_list_branches <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    "GET",
    paste0("/repositories/", project_id, "/branches"),
    conn = conn
  )
  as.character(unlist(payload, use.names = FALSE))
}

#' Get the default branch name
#'
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character branch name, or `NULL` if unset (HTTP 204).
#' @export
od_get_default_branch <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    "GET",
    paste0("/repositories/", project_id, "/default-branch"),
    conn = conn
  )
  if (is.null(payload) || !nzchar(as.character(payload)[1])) {
    return(NULL)
  }
  as.character(payload)[1]
}

#' Get branch tip metadata
#'
#' @param branch Branch name.
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return List with `refName` and `commitHash`.
#' @export
od_get_branch <- function(branch, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  branch <- trimws(as.character(branch %||% "")[1])
  if (!nzchar(branch)) {
    stop("`branch` is required.", call. = FALSE)
  }
  project_id <- od_resolve_project_id(project = project, conn = conn)
  encoded <- utils::URLencode(branch, reserved = TRUE)
  od_request(
    "GET",
    paste0("/repositories/", project_id, "/branches/", encoded),
    conn = conn
  )
}

#' List tags in a project
#'
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character vector of tag names.
#' @export
od_list_tags <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    "GET",
    paste0("/repositories/", project_id, "/tags"),
    conn = conn
  )
  as.character(unlist(payload, use.names = FALSE))
}

#' Get tag tip metadata
#'
#' @param tag Tag name.
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return List with `refName` and `commitHash`.
#' @export
od_get_tag <- function(tag, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  tag <- trimws(as.character(tag %||% "")[1])
  if (!nzchar(tag)) {
    stop("`tag` is required.", call. = FALSE)
  }
  project_id <- od_resolve_project_id(project = project, conn = conn)
  encoded <- utils::URLencode(tag, reserved = TRUE)
  od_request(
    "GET",
    paste0("/repositories/", project_id, "/tags/", encoded),
    conn = conn
  )
}

#' Query repository commits
#'
#' Calls `GET /repositories/{projectId}/commits`.
#'
#' @param query OneDev commit query (same syntax as the commits page), e.g.
#'   `"since tag(v1.0.0) until tag(v2.0.0)"`.
#' @param count Maximum number of commits (default `100`).
#' @param fields Character vector of fields to populate (default includes
#'   author/subject/body/parents/dates).
#' @param project Project path or id; defaults to the connection project.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of commits (default), or a list when `as_tibble = FALSE`.
#' @export
od_query_commits <- function(
  query = NULL,
  count = 100L,
  fields = .od_default_commit_fields(),
  project = NULL,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    method = "GET",
    endpoint = paste0("/repositories/", project_id, "/commits"),
    query = .od_repo_commit_query(query = query, count = count, fields = fields),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a single commit
#'
#' @param commit_hash Commit SHA.
#' @param fields Character vector of fields to populate.
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed commit object (list).
#' @export
od_get_commit <- function(
  commit_hash,
  fields = .od_default_commit_fields(),
  project = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  commit_hash <- trimws(as.character(commit_hash %||% "")[1])
  if (!nzchar(commit_hash)) {
    stop("`commit_hash` is required.", call. = FALSE)
  }
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request(
    method = "GET",
    endpoint = paste0("/repositories/", project_id, "/commits/", commit_hash),
    query = .od_repo_commit_query(fields = fields),
    conn = conn
  )
}

#' Get a file at a revision
#'
#' Calls `GET /repositories/{projectId}/files/{revision}/{path...}`.
#'
#' @param revision Branch, tag, or commit.
#' @param path File path within the repository.
#' @param project Project path or id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed file payload (list; typically includes base64 content).
#' @export
od_get_file <- function(revision, path, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  revision <- trimws(as.character(revision %||% "")[1])
  path <- trimws(as.character(path %||% "")[1])
  path <- sub("^/+", "", path)
  if (!nzchar(revision) || !nzchar(path)) {
    stop("`revision` and `path` are required.", call. = FALSE)
  }
  project_id <- od_resolve_project_id(project = project, conn = conn)
  encoded <- .od_repo_path_encode(
    c(revision, strsplit(path, "/", fixed = TRUE)[[1]])
  )
  od_request(
    "GET",
    paste0("/repositories/", project_id, "/files/", encoded),
    conn = conn
  )
}
