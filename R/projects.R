#' Resolve the OneDev project path for a connection
#'
#' Uses `conn$project_path`, falling back to deriving a path from
#' `conn$repo_url` (git remote URL).
#'
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character project path (e.g. `"group/my-project"`).
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
