#' Normalize job params to OneDev's map-of-string-lists shape
#'
#' Accepts a named list/vector where each element is a character scalar or
#' vector of values.
#' @keywords internal
.od_job_params <- function(params = NULL) {
  if (is.null(params) || length(params) == 0L) {
    return(stats::setNames(list(), character()))
  }
  if (is.null(names(params)) || any(!nzchar(names(params)))) {
    stop("`params` must be a named list (param name -> value(s)).", call. = FALSE)
  }
  out <- lapply(params, function(v) {
    as.character(unlist(v, use.names = FALSE))
  })
  names(out) <- names(params)
  out
}

#' Build a git refs/heads or refs/tags name
#' @keywords internal
.od_git_ref <- function(branch = NULL, tag = NULL) {
  branch <- trimws(as.character(branch %||% "")[1])
  tag <- trimws(as.character(tag %||% "")[1])
  if (nzchar(branch) && nzchar(tag)) {
    stop("Specify only one of `branch` or `tag`.", call. = FALSE)
  }
  if (nzchar(branch)) {
    if (startsWith(branch, "refs/")) branch else paste0("refs/heads/", branch)
  } else if (nzchar(tag)) {
    if (startsWith(tag, "refs/")) tag else paste0("refs/tags/", tag)
  } else {
    ""
  }
}

#' Run a CI/CD job
#'
#' Posts to `POST /job-runs`. Prefer `branch` / `tag` (resolves tip commit +
#' ref), or pass `commit_hash` + `ref_name` explicitly. For pull-request merge
#' previews, pass `pull_request_id` (internal REST id).
#'
#' Returns the internal build id (numeric). Use [od_get_build()] with
#' `use_internal_id = TRUE` or query by number once known.
#'
#' @param job_name Job name from the project build spec.
#' @param project Project path or id; defaults to the connection project.
#' @param branch Branch name (e.g. `"main"`) — mutually exclusive with `tag`,
#'   `commit_hash`, and `pull_request_id`.
#' @param tag Tag name — mutually exclusive with `branch` / commit / PR modes.
#' @param commit_hash Commit SHA to build (requires `ref_name`).
#' @param ref_name Full git ref (e.g. `"refs/heads/main"`) when using
#'   `commit_hash`.
#' @param pull_request_id Internal pull request id (not the UI number).
#' @param params Named list of job parameters (values are character scalars or
#'   vectors for multi-valued params).
#' @param reason Reason string recorded on the build (required by OneDev).
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Internal build id (numeric/character as returned by the API).
#' @export
od_run_job <- function(
  job_name,
  project = NULL,
  branch = NULL,
  tag = NULL,
  commit_hash = NULL,
  ref_name = NULL,
  pull_request_id = NULL,
  params = NULL,
  reason = "Submitted via onedevr",
  conn = NULL
) {
  conn <- .od_conn(conn)
  job_name <- trimws(as.character(job_name %||% "")[1])
  reason <- trimws(as.character(reason %||% "")[1])
  if (!nzchar(job_name)) {
    stop("`job_name` is required.", call. = FALSE)
  }
  if (!nzchar(reason)) {
    stop("`reason` is required.", call. = FALSE)
  }

  job_params <- .od_job_params(params)
  pr_id <- trimws(as.character(pull_request_id %||% "")[1])
  commit_hash <- trimws(as.character(commit_hash %||% "")[1])
  ref_name <- trimws(as.character(ref_name %||% "")[1])
  branch <- trimws(as.character(branch %||% "")[1])
  tag <- trimws(as.character(tag %||% "")[1])

  modes <- sum(c(
    nzchar(pr_id),
    nzchar(commit_hash) || nzchar(ref_name),
    nzchar(branch) || nzchar(tag)
  ))
  if (modes > 1L) {
    stop(
      "Specify only one run mode: `pull_request_id`, `commit_hash`+`ref_name`, or `branch`/`tag`.",
      call. = FALSE
    )
  }

  if (nzchar(pr_id)) {
    body <- list(
      `@type` = "JobRunOnPullRequest",
      pullRequestId = as.integer(pr_id),
      jobName = job_name,
      params = job_params,
      reason = reason
    )
  } else {
    project_id <- as.integer(od_resolve_project_id(project = project, conn = conn))

    if (!nzchar(commit_hash)) {
      if (!nzchar(branch) && !nzchar(tag)) {
        stop("Provide `branch`, `tag`, or `commit_hash` + `ref_name`.", call. = FALSE)
      }
      if (nzchar(branch)) {
        tip <- od_get_branch(branch, project = project, conn = conn)
        commit_hash <- tip$commitHash %||% tip$commit_hash %||% ""
        ref_name <- tip$refName %||% tip$ref_name %||% .od_git_ref(branch = branch)
      } else {
        tip <- od_get_tag(tag, project = project, conn = conn)
        commit_hash <- tip$commitHash %||% tip$commit_hash %||% ""
        ref_name <- tip$refName %||% tip$ref_name %||% .od_git_ref(tag = tag)
      }
      commit_hash <- as.character(commit_hash)[1]
      ref_name <- as.character(ref_name)[1]
    }

    if (!nzchar(commit_hash) || !nzchar(ref_name)) {
      stop("`commit_hash` and `ref_name` are required for JobRunOnCommit.", call. = FALSE)
    }

    body <- list(
      `@type` = "JobRunOnCommit",
      projectId = project_id,
      commitHash = commit_hash,
      refName = ref_name,
      jobName = job_name,
      params = job_params,
      reason = reason
    )
  }

  od_request(method = "POST", endpoint = "/job-runs", body = body, conn = conn)
}

#' Rebuild (resubmit) a finished or existing build
#'
#' Posts to `POST /job-runs/rebuild`.
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param reason Reason string (required by OneDev).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return `NULL` invisibly on success (empty API body).
#' @export
od_rebuild_job <- function(
  build_number,
  reason = "Rebuild via onedevr",
  conn = NULL,
  use_internal_id = FALSE
) {
  conn <- .od_conn(conn)
  reason <- trimws(as.character(reason %||% "")[1])
  if (!nzchar(reason)) {
    stop("`reason` is required.", call. = FALSE)
  }
  build_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
  od_request(
    method = "POST",
    endpoint = "/job-runs/rebuild",
    body = list(
      buildId = as.integer(build_id),
      reason = reason
    ),
    conn = conn
  )
  invisible(NULL)
}

#' Cancel a running build
#'
#' Calls `DELETE /job-runs/{buildId}`.
#'
#' @param build_number UI number (`100` or `"#100"`).
#' @param conn Connection list.
#' @param use_internal_id If `TRUE`, treat `build_number` as the internal REST id.
#' @return `NULL` invisibly on success.
#' @export
od_cancel_job <- function(build_number, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  build_id <- if (isTRUE(use_internal_id)) {
    .od_strip_hash(build_number)
  } else {
    od_resolve_build_id(build_number, conn = conn)
  }
  od_request(
    method = "DELETE",
    endpoint = paste0("/job-runs/", build_id),
    conn = conn
  )
  invisible(NULL)
}
