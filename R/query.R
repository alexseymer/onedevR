#' Fetch OneDev query DSL description text
#'
#' Calls `/~api/tod/get-{kind}-query-description` (same source `tod … get-query-description`
#' uses). Useful when crafting `query =` strings for list helpers.
#'
#' @param kind One of `"issue"`, `"build"`, `"pull_request"`, or `"project"`.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character scalar (HTML-ish grammar text from the server).
#' @family utilities
#' @examples
#' \dontrun{
#' cat(od_get_query_description("build"))
#' }
#' @export
od_get_query_description <- function(
  kind = c("issue", "build", "pull_request", "project"),
  conn = NULL
) {
  conn <- .od_conn(conn)
  kind <- match.arg(kind)
  endpoint <- switch(
    kind,
    issue = "/tod/get-issue-query-description",
    build = "/tod/get-build-query-description",
    pull_request = "/tod/get-pull-request-query-description",
    project = "/tod/get-project-query-description"
  )
  payload <- od_request("GET", endpoint, conn = conn)
  as.character(payload)[1]
}

#' Paginate a list/query helper until exhausted
#'
#' Repeatedly calls `fetcher(offset, count)` (and optional `as_tibble`) until a
#' short page is returned or `max_pages` is hit. Designed for
#' [od_query_issues()], [od_query_builds()], [od_query_projects()], etc.
#'
#' @param fetcher A function that accepts at least `offset` and `count`. Extra
#'   arguments may be passed via `...`.
#' @param ... Forwarded to `fetcher` (e.g. `state = "Open"`, `query = ...`).
#' @param page_size Page size / `count` (default `100`).
#' @param max_pages Safety cap on number of pages (default `100`).
#' @param as_tibble Passed to `fetcher` when it has a formal `as_tibble`.
#' @return A combined tibble when pages are tibbles; otherwise a concatenated
#'   list of items.
#' @family utilities
#' @examples
#' \dontrun{
#' od_paginate(od_query_issues, state = "Open", page_size = 50L)
#' }
#' @export
od_paginate <- function(
  fetcher,
  ...,
  page_size = 100L,
  max_pages = 100L,
  as_tibble = NULL
) {
  if (!is.function(fetcher)) {
    stop("`fetcher` must be a function.", call. = FALSE)
  }
  page_size <- as.integer(page_size)[1]
  max_pages <- as.integer(max_pages)[1]
  if (page_size < 1L) {
    stop("`page_size` must be >= 1.", call. = FALSE)
  }

  formals_names <- names(formals(fetcher))
  offset <- 0L
  pages <- list()

  for (i in seq_len(max_pages)) {
    args <- list(..., offset = offset, count = page_size)
    if ("as_tibble" %in% formals_names) {
      args$as_tibble <- as_tibble
    }
    page <- do.call(fetcher, args)
    pages[[length(pages) + 1L]] <- page

    n <- if (inherits(page, "data.frame")) {
      nrow(page)
    } else {
      length(.od_normalize_collection(page))
    }
    if (n < page_size) {
      break
    }
    offset <- offset + page_size
  }

  if (!length(pages)) {
    return(if (isTRUE(.od_as_tibble_default(as_tibble))) tibble::tibble() else list())
  }

  if (inherits(pages[[1]], "data.frame")) {
    # vctrs (pulled in by tibble) binds list-columns without rowname clashes
    out <- do.call(vec_rbind, pages)
    return(tibble::as_tibble(out))
  }

  unlist(lapply(pages, .od_normalize_collection), recursive = FALSE)
}
