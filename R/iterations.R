#' List iterations for a OneDev project
#'
#' Calls `GET /projects/{id}/iterations`. Iteration ids are installation- and
#' project-specific; use them with [od_add_issue_iterations()] or
#' [od_create_issue()]'s `iteration_ids` argument.
#'
#' @param project Optional project path or numeric id; defaults to the
#'   connection's project via [od_resolve_project_id()].
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of iterations (default), or a list when `as_tibble = FALSE`.
#' @family issues
#' @examples
#' \dontrun{
#' od_list_iterations()
#' }
#' @export
od_list_iterations <- function(
  project = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    method = "GET",
    endpoint = paste0("/projects/", project_id, "/iterations"),
    query = list(
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Set iterations on an existing issue
#'
#' Calls `POST /issues/{id}/iterations`. Tries known body shapes (raw id list
#' and `{iterationIds: [...]}`) via the variants helper - see
#' `project_plan.md` sec 10.
#'
#' @param issue_number UI number (`145` or `"#145"`).
#' @param iteration_ids Numeric iteration ids from [od_list_iterations()].
#' @param conn Connection list.
#' @return Parsed API response.
#' @family issues
#' @examples
#' \dontrun{
#' od_add_issue_iterations(145, iteration_ids = 17L)
#' }
#' @export
od_add_issue_iterations <- function(issue_number, iteration_ids, conn = NULL) {
  conn <- .od_conn(conn)
  if (is.null(iteration_ids) || length(iteration_ids) < 1L) {
    stop("`iteration_ids` must contain at least one id.", call. = FALSE)
  }
  ids <- as.list(as.integer(iteration_ids))
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)

  .od_request_with_variants(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/iterations"),
    body_variants = list(
      ids,
      list(iterationIds = ids)
    ),
    conn = conn
  )
}
