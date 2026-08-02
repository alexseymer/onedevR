#' Resolve a markdown resource URL against the OneDev host
#'
#' Absolute `http(s)` URLs are returned unchanged; relative URLs are resolved
#' against `host` (same idea as `tod download`).
#'
#' @param host OneDev base URL (no `/~api` suffix).
#' @param resource_url Absolute or relative resource URL from markdown.
#' @return Absolute URL string.
#' @noRd
.od_resolve_markdown_url <- function(host, resource_url) {
  resource_url <- trimws(as.character(resource_url %||% "")[1])
  if (!nzchar(resource_url)) {
    stop("`resource_url` is missing or empty.", call. = FALSE)
  }
  if (grepl("^https?://", resource_url, ignore.case = TRUE)) {
    return(resource_url)
  }

  host <- sub("/+$", "", trimws(as.character(host %||% "")[1]))
  if (!nzchar(host)) {
    stop("No host available to resolve relative resource URL.", call. = FALSE)
  }
  if (startsWith(resource_url, "/")) {
    paste0(host, resource_url)
  } else {
    paste0(host, "/", resource_url)
  }
}

#' Download a markdown-referenced resource with OneDev auth
#'
#' Mirrors `tod download`: fetch an absolute or host-relative URL using the
#' connection credentials and write the body to `path`. Useful for images and
#' files linked from issue/PR descriptions and comments (OneDev has no separate
#' attachment list API).
#'
#' @param resource_url Absolute `http(s)` URL or path relative to the OneDev host.
#' @param path Local destination file path.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Normalized destination path, invisibly.
#' @family utilities
#' @examples
#' \dontrun{
#' od_download("/~downloads/file.png", tempfile())
#' }
#' @export
od_download <- function(resource_url, path, conn = NULL) {
  conn <- .od_conn(conn)
  path <- as.character(path)[1]
  if (!nzchar(path)) {
    stop("`path` is required.", call. = FALSE)
  }

  url <- .od_resolve_markdown_url(conn$host %||% "", resource_url)
  raw <- .od_request_raw(
    method = "GET",
    endpoint = url,
    conn = conn,
    accept = "*/*"
  )
  dir <- dirname(path)
  if (!dir.exists(dir) && !identical(dir, ".")) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  }
  writeBin(raw, path)
  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
}
