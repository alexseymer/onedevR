#' Resolve the OneDev project path for a connection
#'
#' Uses `conn$project_path`, falling back to deriving a path from
#' `conn$repo_url` (git remote URL).
#'
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {character} Character project path (e.g. `"group/my-project"`).
#' @family projects
#' @examples
#' \dontrun{
#' od_resolve_project_path()
#' }
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
#' @param project {character} Optional project path; defaults to [od_resolve_project_path()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {character} Character project id.
#' @endpoint GET /projects/ids/{projectPath}
#' @family projects
#' @examples
#' \dontrun{
#' od_resolve_project_id()
#' }
#' @export
od_resolve_project_id <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)

  if (is.null(project) || !nzchar(as.character(project)[1])) {
    if (nzchar(conn$project_id %||% "")) {
      return(as.character(conn$project_id))
    }
    project <- od_resolve_project_path(conn = conn)
  }

  project <- .od_coerce_string(project)
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

#' Query OneDev projects
#'
#' Calls `GET /projects` with OneDev's project query DSL (see
#' `tod project get-query-description` on a live server).
#'
#' @param query {character} Raw OneDev project query string. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`).
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of projects (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /projects
#' @family projects
#' @examples
#' \dontrun{
#' od_query_projects(count = 20L)
#' }
#' @export
od_query_projects <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- .od_coerce_string(query)
  payload <- od_request(
    method = "GET",
    endpoint = "/projects",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' @param query {character} Raw OneDev project query string. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`).
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of projects (default), or a list when `as_tibble = FALSE`.
#' @rdname od_query_projects
#' @family projects
#' @examples
#' \dontrun{
#' od_list_projects(count = 20L)
#' }
#' @export
od_list_projects <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  od_query_projects(
    query = query,
    count = count,
    offset = offset,
    as_tibble = as_tibble,
    conn = conn
  )
}
#' Get a single project
#'
#' @param project {character|numeric} Project path (e.g. `"group/my-project"`) or numeric id.
#'   Defaults to the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed project object.
#' @endpoint GET /projects/{projectId}
#' @family projects
#' @examples
#' \dontrun{
#' od_get_project()
#' }
#' @export
od_get_project <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request("GET", paste0("/projects/", project_id), conn = conn)
}

#' Get clone URLs for a project
#'
#' @param project {character|numeric} Project path or numeric id; defaults to the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed clone-url payload (typically `http` and `ssh` keys).
#' @endpoint GET /projects/{projectId}/clone-url
#' @family projects
#' @examples
#' \dontrun{
#' od_get_project_clone_url()
#' }
#' @export
od_get_project_clone_url <- function(project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request("GET", paste0("/projects/", project_id, "/clone-url"), conn = conn)
}

#' List webhooks for a project
#'
#' Retrieves all webhooks configured for a project.
#'
#' @param project {character|numeric} Project path or numeric id; defaults to the connection project. Default: `NULL`.
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of webhooks (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /projects/{projectId}/webhooks
#' @family projects
#' @examples
#' \dontrun{
#' od_list_webhooks()
#' }
#' @export
od_list_webhooks <- function(project = NULL, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  project_id <- od_resolve_project_id(project = project, conn = conn)
  payload <- od_request(
    "GET",
    paste0("/projects/", project_id, "/webhooks"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a webhook by ID
#'
#' Retrieves details for a specific webhook.
#'
#' @param webhook_id {character|numeric} Numeric webhook ID.
#' @param project {character|numeric} Project path or numeric id; defaults to the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed webhook object.
#' @endpoint GET /projects/{projectId}/webhooks/{webhookId}
#' @family projects
#' @examples
#' \dontrun{
#' od_get_webhook(1)
#' }
#' @export
od_get_webhook <- function(webhook_id, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  webhook_id <- .od_coerce_string(webhook_id)
  .od_require(webhook_id, "webhook_id")
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request(
    "GET",
    paste0("/projects/", project_id, "/webhooks/", webhook_id),
    conn = conn
  )
}

#' Create a webhook for a project
#'
#' Creates a new webhook that will POST events to the specified URL.
#'
#' @param url {character} Target URL where webhook events will be POSTed.
#' @param events {character} Character vector of event types to trigger on (e.g., c("push", "pull_request")).
#'   Omit or pass `NULL` for all events. Default: `NULL`.
#' @param project {character|numeric} Project path or numeric id; defaults to the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed webhook object with ID and configuration.
#' @family projects
#' @examples
#' \dontrun{
#' od_create_webhook("https://example.com/webhook", events = c("push", "pull_request"))
#' }
#' @export
od_create_webhook <- function(url, events = NULL, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  url <- .od_coerce_string(url)
  .od_require(url, "url")
  project_id <- od_resolve_project_id(project = project, conn = conn)

  body <- list(url = url)
  if (!is.null(events) && length(events) > 0) {
    body$events <- as.character(events)
  }

  od_request(
    method = "POST",
    endpoint = paste0("/projects/", project_id, "/webhooks"),
    body = body,
    conn = conn
  )
}

#' Delete a webhook
#'
#' Removes a webhook from a project.
#'
#' @param webhook_id {character|numeric} Numeric webhook ID.
#' @param project {character|numeric} Project path or numeric id; defaults to the connection project. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response (typically `NULL` on success).
#' @family projects
#' @examples
#' \dontrun{
#' od_delete_webhook(1)
#' }
#' @export
od_delete_webhook <- function(webhook_id, project = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  webhook_id <- .od_coerce_string(webhook_id)
  .od_require(webhook_id, "webhook_id")
  project_id <- od_resolve_project_id(project = project, conn = conn)
  od_request(
    method = "DELETE",
    endpoint = paste0("/projects/", project_id, "/webhooks/", webhook_id),
    conn = conn
  )
}
