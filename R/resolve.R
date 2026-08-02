#' Build OneDev `"Number" is "..."` query variants for a UI number
#'
#' Some OneDev versions accept `path#n`; others only accept bare `n` / `#n`
#' (path-prefixed values return HTTP 406 "Invalid number"). Try path form
#' first, then bare forms.
#'
#' @noRd
.od_number_query_variants <- function(project_path, number) {
  numeric_part <- .od_strip_hash(number)
  project_path <- trimws(as.character(project_path %||% "")[1])
  variants <- character()
  if (nzchar(project_path)) {
    variants <- c(variants, paste0('"Number" is "', project_path, "#", numeric_part, '"'))
  }
  variants <- c(
    variants,
    paste0('"Number" is "#', numeric_part, '"'),
    paste0('"Number" is "', numeric_part, '"')
  )
  unique(variants)
}

#' Resolve a UI number via query variants until one succeeds
#'
#' @param kind One of `"issue"`, `"build"`, `"pull"`.
#' @param number UI number.
#' @param conn Connection list.
#' @param label Human label for errors (`"issue"`, `"build"`, ...).
#' @return Character internal id.
#' @noRd
.od_resolve_number_id <- function(kind, number, conn, label) {
  project_path <- od_resolve_project_path(conn = conn)
  numeric_part <- .od_strip_hash(number)
  last_error <- NULL

  for (q in .od_number_query_variants(project_path, numeric_part)) {
    outcome <- tryCatch(
      {
        payload <- switch(
          kind,
          issue = od_query_issues(
            query = q, count = 1L, offset = 0L, as_tibble = FALSE, conn = conn
          ),
          build = od_query_builds(
            query = q, count = 1L, offset = 0L, as_tibble = FALSE, conn = conn
          ),
          pull = od_query_pull_requests(
            query = q, count = 1L, offset = 0L, as_tibble = FALSE, conn = conn
          ),
          stop(paste0("Unknown resolve kind: ", kind), call. = FALSE)
        )
        items <- .od_normalize_collection(payload)
        if (length(items) >= 1L && !is.null(items[[1]]$id)) {
          list(ok = TRUE, id = as.character(items[[1]]$id))
        } else {
          list(ok = FALSE, id = NULL)
        }
      },
      error = function(e) {
        last_error <<- e
        list(ok = FALSE, id = NULL)
      }
    )
    if (isTRUE(outcome$ok)) {
      return(outcome$id)
    }
  }

  if (!is.null(last_error)) {
    stop(conditionMessage(last_error), call. = FALSE)
  }
  stop(paste0("OneDev ", label, " #", numeric_part, " was not found."), call. = FALSE)
}

#' Resolve a UI issue number to the internal REST id
#'
#' OneDev UI numbers (`#145`) differ from internal REST `id` values. High-level
#' helpers always take the UI number. Tries `"Number" is "<projectPath>#<n>"`
#' then bare `"#n"` / `"n"` (same idea as [tod](https://github.com/theonedev/tod);
#' bare forms are required on some OneDev versions).
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal issue id.
#' @family issues
#' @examples
#' \dontrun{
#' od_resolve_issue_id(145)
#' }
#' @export
od_resolve_issue_id <- function(issue_number, conn = NULL) {
  conn <- .od_conn(conn)
  .od_resolve_number_id("issue", issue_number, conn, "issue")
}

#' Resolve a UI build number to the internal REST id
#'
#' Same Number-query variants as [od_resolve_issue_id()].
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal build id.
#' @family builds
#' @examples
#' \dontrun{
#' od_resolve_build_id(100)
#' }
#' @export
od_resolve_build_id <- function(build_number, conn = NULL) {
  conn <- .od_conn(conn)
  .od_resolve_number_id("build", build_number, conn, "build")
}

#' Resolve a UI pull request number to the internal REST id
#'
#' Same Number-query variants as [od_resolve_issue_id()].
#'
#' @param pull_request_number UI number (`42` or `"#42"`).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character internal pull request id.
#' @family pull requests
#' @examples
#' \dontrun{
#' od_resolve_pull_request_id(1)
#' }
#' @export
od_resolve_pull_request_id <- function(pull_request_number, conn = NULL) {
  conn <- .od_conn(conn)
  .od_resolve_number_id("pull", pull_request_number, conn, "pull request")
}
