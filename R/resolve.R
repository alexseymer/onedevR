#' Resolve a UI issue number to the internal REST id
#'
#' OneDev UI numbers (`#145`) differ from internal REST `id` values. High-level
#' helpers always take the UI number; this function queries
#' `"Number" is "<projectPath>#<n>"` (same convention as
#' [tod](https://github.com/theonedev/tod)).
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal issue id.
#' @export
od_resolve_issue_id <- function(issue_number, conn = NULL) {
  conn <- .od_conn(conn)
  project_path <- od_resolve_project_path(conn = conn)
  numeric_part <- .od_strip_hash(issue_number)
  ref <- paste0(project_path, "#", numeric_part)
  issues <- .od_normalize_collection(
    od_query_issues(
      query = paste0('"Number" is "', ref, '"'),
      count = 1L,
      offset = 0L,
      conn = conn
    )
  )

  if (length(issues) < 1L || is.null(issues[[1]]$id)) {
    stop(paste0("OneDev issue #", numeric_part, " was not found."), call. = FALSE)
  }

  as.character(issues[[1]]$id)
}

#' Resolve a UI build number to the internal REST id
#'
#' Same `"Number" is "<projectPath>#<n>"` convention as
#' [od_resolve_issue_id()] / [tod](https://github.com/theonedev/tod).
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal build id.
#' @export
od_resolve_build_id <- function(build_number, conn = NULL) {
  conn <- .od_conn(conn)
  project_path <- od_resolve_project_path(conn = conn)
  numeric_part <- .od_strip_hash(build_number)
  ref <- paste0(project_path, "#", numeric_part)
  builds <- .od_normalize_collection(
    od_query_builds(
      query = paste0('"Number" is "', ref, '"'),
      count = 1L,
      offset = 0L,
      conn = conn
    )
  )

  if (length(builds) < 1L || is.null(builds[[1]]$id)) {
    stop(paste0("OneDev build #", numeric_part, " was not found."), call. = FALSE)
  }

  as.character(builds[[1]]$id)
}

#' Resolve a UI pull request number to the internal REST id
#'
#' Same `"Number" is "<projectPath>#<n>"` convention as
#' [od_resolve_issue_id()] / [tod](https://github.com/theonedev/tod).
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal pull request id.
#' @export
od_resolve_pull_request_id <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  project_path <- od_resolve_project_path(conn = conn)
  numeric_part <- .od_strip_hash(pull_request_number)
  ref <- paste0(project_path, "#", numeric_part)
  pulls <- .od_normalize_collection(
    od_query_pull_requests(
      query = paste0('"Number" is "', ref, '"'),
      count = 1L,
      offset = 0L,
      conn = conn
    )
  )

  if (length(pulls) < 1L || is.null(pulls[[1]]$id)) {
    stop(
      paste0("OneDev pull request #", numeric_part, " was not found."),
      call. = FALSE
    )
  }

  as.character(pulls[[1]]$id)
}
