#' Resolve a UI issue number to the internal REST id
#'
#' OneDev UI numbers (`#145`) differ from internal REST `id` values. High-level
#' helpers always take the UI number; this function queries
#' `"Number" is "<projectPath>#<n>"` (same convention as
#' [tod](https://github.com/theonedev/tod)).
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param conn Connection list from [od_get_config()] (or compatible).
#' @return Character internal issue id.
#' @export
od_resolve_issue_id <- function(issue_number, conn = NULL) {
  conn <- conn %||% od_get_config()
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
