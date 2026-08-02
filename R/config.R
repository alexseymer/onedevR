#' Read OneDev connection settings from environment variables
#'
#' Reads `ONEDEV_*` variables (see `.Renviron.example` / `.env.example`) and
#' returns a connection list used by high-level `od_*` helpers. Prefer an
#' explicit [od_connection()] (optionally registered with
#' [od_set_connection()]) for scripts; env remains the fallback when no
#' connection is passed or registered.
#'
#' Auth: Bearer via `ONEDEV_API_TOKEN` (or aliases). Basic Auth when
#' `ONEDEV_USERNAME` is set (password from `ONEDEV_PASSWORD`, or the token as
#' password). Override with `ONEDEV_AUTH=bearer|basic`.
#'
#' @param validate If `TRUE` (default), error when host or credentials are missing.
#'
#' @return A named list with fields `host`, `api_base_url`, `token`, `username`,
#'   `password`, `auth`, `repo_url`, `project_id`, `project_path`,
#'   `default_issue_state`, and `insecure_ssl`.
#'
#' @examples
#' \dontrun{
#' Sys.setenv(
#'   ONEDEV_HOST = "https://git.example.test",
#'   ONEDEV_API_TOKEN = "token",
#'   ONEDEV_PROJECT_PATH = "group/my-project"
#' )
#' od_get_config()
#' }
#' @export
od_get_config <- function(validate = TRUE) {
  host <- .od_trim_env("ONEDEV_HOST")
  token <- .od_first_non_empty(
    .od_trim_env("ONEDEV_API_TOKEN"),
    .od_trim_env("ONEDEV_TOKEN"),
    .od_trim_env("ONEDEV_ISSUE_REPORTER_API_KEY")
  )
  username <- .od_trim_env("ONEDEV_USERNAME")
  password <- .od_trim_env("ONEDEV_PASSWORD")
  auth <- .od_trim_env("ONEDEV_AUTH")
  repo_url <- .od_trim_env("ONEDEV_REPO_URL")
  project_path <- .od_first_non_empty(
    .od_trim_env("ONEDEV_PROJECT_PATH"),
    .od_derive_project_path(repo_url)
  )
  project_id <- .od_trim_env("ONEDEV_PROJECT_ID")
  issue_state <- .od_trim_env("ONEDEV_ISSUE_STATE")
  insecure_ssl <- .od_parse_flag(.od_trim_env("ONEDEV_CURL_INSECURE"))

  host <- sub("/+$", "", host)
  auth_mode <- .od_infer_auth(auth, username, token, password)

  conn <- list(
    host = host,
    api_base_url = if (nzchar(host)) paste0(host, "/~api") else "",
    token = token,
    username = username,
    password = password,
    auth = auth_mode,
    repo_url = repo_url,
    project_id = project_id,
    project_path = project_path,
    default_issue_state = issue_state,
    insecure_ssl = insecure_ssl
  )

  if (isTRUE(validate)) {
    if (!nzchar(conn$host)) {
      stop("ONEDEV_HOST is missing or empty.", call. = FALSE)
    }
    tryCatch(
      .od_validate_auth(conn, context = "od_get_config()"),
      error = function(e) {
        if (identical(auth_mode, "bearer")) {
          stop(
            "No OneDev token found. Expected: ONEDEV_API_TOKEN, ONEDEV_TOKEN, or ONEDEV_ISSUE_REPORTER_API_KEY (or set ONEDEV_USERNAME for Basic Auth).",
            call. = FALSE
          )
        }
        stop(conditionMessage(e), call. = FALSE)
      }
    )
  }

  conn
}
