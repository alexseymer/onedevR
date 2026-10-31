#' List issue boards for a OneDev project
#'
#' Boards are not a separate REST resource; they live in project settings as
#' `issueSetting$boardSpecs` (see [od_get_project_setting()]). This helper
#' extracts that list.
#'
#' @param project {character|numeric} Project path or numeric id; defaults to
#'   the connection project. Default: `NULL`.
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`),
#'   return a tibble via [od_as_tibble()]; if `FALSE`, the raw list of board
#'   specs. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()].
#'   Default: `NULL`.
#' @return {tibble|list} Board specs (default tibble), or an empty tibble/list
#'   when none are configured.
#' @family issues
#' @examples
#' \dontrun{
#' od_list_boards()
#' }
#' @export
od_list_boards <- function(project = NULL, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  setting <- od_get_project_setting(project = project, conn = conn)
  specs <- setting$issueSetting$boardSpecs
  if (is.null(specs)) {
    specs <- list()
  }
  od_as_tibble(specs, as_tibble = as_tibble)
}

#' Get a single issue board by name
#'
#' @param name {character} Board name (case-sensitive), as shown in the OneDev UI.
#' @param project {character|numeric} Project path or numeric id; defaults to
#'   the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()].
#'   Default: `NULL`.
#' @return {list} A single board spec (name, baseQuery, backlogBaseQuery,
#'   columns, identifyField, …).
#' @family issues
#' @examples
#' \dontrun{
#' od_get_board("Development")
#' }
#' @export
od_get_board <- function(name, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  name <- .od_coerce_string(name)
  .od_require(name, "name")

  boards <- od_list_boards(
    project = project,
    as_tibble = FALSE,
    conn = conn
  )
  names_vec <- vapply(
    boards,
    function(b) .od_coerce_string(b$name %||% ""),
    character(1)
  )
  idx <- which(names_vec == name)
  if (!length(idx)) {
    stop(
      paste0("OneDev board '", name, "' was not found in project settings."),
      call. = FALSE
    )
  }
  boards[[idx[[1]]]]
}

#' Query issues visible on a board
#'
#' Composes the board's `baseQuery` (or `backlogBaseQuery` when `backlog = TRUE`)
#' with an optional iteration filter, then calls [od_query_issues()]. Does not
#' inject `conn$default_issue_state` — board queries already encode workflow
#' state.
#'
#' @param board {character|list} Board name, or a board list from
#'   [od_get_board()] / [od_list_boards()].
#' @param iteration {character|NULL} Optional iteration name to AND into the
#'   query (`"Iteration" is "…"`). Default: `NULL`.
#' @param backlog {logical} If `TRUE`, use `backlogBaseQuery` instead of
#'   `baseQuery`. Default: `FALSE`.
#' @param count {integer} Maximum number of results (default `100`).
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} Passed to [od_query_issues()]. Default: `NULL`.
#' @param project {character|numeric} Project path or numeric id when `board`
#'   is a name. Default: `NULL`.
#' @param conn {list} Connection list. Default: `NULL`.
#' @return {tibble|list} Issues matching the composed board query.
#' @family issues
#' @examples
#' \dontrun{
#' od_query_board_issues("Development")
#' od_query_board_issues("Development", iteration = "Sprint 5")
#' od_query_board_issues("Development", backlog = TRUE)
#' }
#' @export
od_query_board_issues <- function(
  board,
  iteration = NULL,
  backlog = FALSE,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  project = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)

  if (is.character(board) || is.numeric(board)) {
    board <- od_get_board(
      name = .od_coerce_string(board),
      project = project,
      conn = conn
    )
  }
  if (!is.list(board)) {
    stop("`board` must be a board name or a board list object.", call. = FALSE)
  }

  base <- if (isTRUE(backlog)) {
    .od_coerce_string(board$backlogBaseQuery %||% "")
  } else {
    .od_coerce_string(board$baseQuery %||% "")
  }

  iteration <- .od_coerce_string(iteration)
  iter_clause <- if (nzchar(iteration)) {
    paste0('"Iteration" is ', .od_quote_query_value(iteration))
  } else {
    ""
  }

  query <- if (nzchar(base) && nzchar(iter_clause)) {
    paste0("(", base, ") and ", iter_clause)
  } else if (nzchar(base)) {
    base
  } else if (nzchar(iter_clause)) {
    iter_clause
  } else {
    ""
  }

  # Avoid od_query_issues injecting conn$default_issue_state when the board
  # query is empty (match-all / no baseQuery).
  call_conn <- conn
  if (!nzchar(query)) {
    call_conn$default_issue_state <- ""
  }

  od_query_issues(
    query = if (nzchar(query)) query else NULL,
    state = NULL,
    count = count,
    offset = offset,
    as_tibble = as_tibble,
    conn = call_conn
  )
}
