#' Normalize an artifact path for OneDev artifact endpoints
#' @keywords internal
.od_artifact_path <- function(artifact_path = NULL, leading_slash = FALSE) {
  path <- trimws(as.character(artifact_path %||% "")[1])
  path <- sub("^/+", "", path)
  if (!nzchar(path)) {
    return("")
  }
  encoded <- paste(
    vapply(
      strsplit(path, "/", fixed = TRUE)[[1]],
      utils::URLencode,
      character(1),
      reserved = TRUE
    ),
    collapse = "/"
  )
  if (isTRUE(leading_slash)) paste0("/", encoded) else encoded
}

#' Resolve a build UI number to internal id for artifact calls
#' @keywords internal
.od_artifact_build_id <- function(build_number, conn, use_internal_id = FALSE) {
  if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
}

#' List build artifact metadata
#'
#' Calls `GET /artifacts/{buildId}/infos[/{path}]`. Omit `artifact_path` for the
#' artifact root; pass a relative path to list a subdirectory.
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param artifact_path Optional relative artifact path (no leading `/`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return A tibble of artifact info (default), or a list when `as_tibble = FALSE`.
#' @export
od_list_build_artifacts <- function(
  build_number,
  artifact_path = NULL,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  build_id <- .od_artifact_build_id(build_number, conn, use_internal_id)
  suffix <- .od_artifact_path(artifact_path, leading_slash = TRUE)
  payload <- od_request(
    "GET",
    paste0("/artifacts/", build_id, "/infos", suffix),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Download a build artifact to a local file
#'
#' Calls `GET /artifacts/{buildId}/contents/{artifactPath}` and writes the raw
#' bytes to `path`.
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param artifact_path Relative artifact path (required).
#' @param path Local destination file path.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return Normalized destination path, invisibly.
#' @export
od_download_build_artifact <- function(
  build_number,
  artifact_path,
  path,
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  build_id <- .od_artifact_build_id(build_number, conn, use_internal_id)
  rel <- .od_artifact_path(artifact_path, leading_slash = FALSE)
  if (!nzchar(rel)) {
    stop("`artifact_path` is required.", call. = FALSE)
  }
  path <- as.character(path)[1]
  if (!nzchar(path)) {
    stop("`path` is required.", call. = FALSE)
  }

  raw <- .od_request_raw(
    method = "GET",
    endpoint = paste0("/artifacts/", build_id, "/contents/", rel),
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
