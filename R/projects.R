#' Resolve the OneDev project path for a connection
#'
#' Uses `conn$project_path`, falling back to deriving a path from
#' `conn$repo_url` (git remote URL).
#'
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character project path (e.g. `"group/my-project"`).
#' @family projects
#' @examples
#' \dontrun{
#' od_resolve_project_path()
#' }
#' @export
od_resolve_project_path <- function(conn = NULL) {
  conn <- .od_conn(conn)
  path <- .od_first_non_empty(
    conn$project_path,
    .od_derive_project_path(conn$repo_url %||% "")
  )
  if (!nzchar(path)) {
    stop(
      "No project path available (set ONEDEV_PROJECT_PATH or ONEDEV_REPO_URL).",
      call. = FALSE
    )
  }
  path
}

#' Resolve a OneDev project path to its numeric project id
#'
#' Calls `GET /projects/ids/{path}`. If `conn$project_id` is already set, that
#' value is returned without a network call.
#'
#' @param project Optional project path; defaults to [od_resolve_project_path()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character project id.
#' @family projects
#' @examples
#' \dontrun{
#' od_resolve_project_id()
#' }
#' @export
od_resolve_project_id <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)

  if (is.null(project) || !nzchar(as.character(project)[1])) {
    if (nzchar(conn$project_id %||% "")) {
      return(as.character(conn$project_id))
    }
    project <- od_resolve_project_path(conn = conn)
  }

  project <- trimws(as.character(project)[1])
  # Numeric path argument is treated as an already-resolved id
  if (grepl("^[0-9]+$", project)) {
    return(project)
  }

  encoded <- paste(vapply(
    strsplit(project, "/", fixed = TRUE)[[1]],
    utils::URLencode, character(1), reserved = TRUE
  ), collapse = "/")

  result <- od_request(
    method = "GET",
    endpoint = paste0("/projects/ids/", encoded),
    conn = conn
  )

  id <- if (is.list(result)) result$id %||% result else result
  if (is.null(id) || !nzchar(as.character(id)[1])) {
    stop(paste0("Could not resolve OneDev project id for path '", project, "'."), call. = FALSE)
  }
  as.character(id)[1]
}

#' Query OneDev projects
#'
#' Calls `GET /projects` with OneDev's project query DSL (see
#' `tod project get-query-description` on a live server).
#'
#' @param query Raw OneDev project query string.
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of projects (default), or a list when `as_tibble = FALSE`.
#' @family projects
#' @examples
#' \dontrun{
#' od_query_projects(count = 20L)
#' }
#' @export
od_query_projects <- function(
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
    endpoint = "/projects",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' @rdname od_query_projects
#' @family projects
#' @examples
#' \dontrun{
#' od_list_projects(count = 20L)
#' }
#' @export
od_list_projects <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  od_query_projects(
    query = query,
    count = count,
    offset = offset,
    as_tibble = as_tibble,
    conn = conn
  )
}
#' Get a single project
#'
#' @param project Project path (e.g. `"group/my-project"`) or numeric id.
#'   Defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed project object (list).
#' @family projects
#' @examples
#' \dontrun{
#' od_get_project()
#' }
#' @export
od_get_project <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request("GET", paste0("/projects/", project_id), conn = conn)
}

#' Get clone URLs for a project
#'
#' @param project Project path or numeric id; defaults to the connection project.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed clone-url payload (list; typically `http` and `ssh`).
#' @family projects
#' @examples
#' \dontrun{
#' od_get_project_clone_url()
#' }
#' @export
od_get_project_clone_url <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request("GET", paste0("/projects/", project_id, "/clone-url"), conn = conn)
}
