#' Resolve a OneDev login name to its numeric user id
#'
#' Calls `GET /users/ids/{name}`. Numeric `user` values are returned as-is.
#'
#' @param user Login name or numeric user id.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Character user id.
#' @family users
#' @examples
#' \dontrun{
#' od_resolve_user_id("alice")
#' }
#' @export
od_resolve_user_id <- function(user, conn = NULL) {
  conn <- .od_conn(conn)
  user <- .od_coerce_string(user)
  if (!nzchar(user)) {
    stop("`user` is missing or empty.", call. = FALSE)
  }
  if (grepl("^[0-9]+$", user)) {
    return(user)
  }

  encoded <- utils::URLencode(user, reserved = TRUE)
  result <- od_request(
    method = "GET",
    endpoint = paste0("/users/ids/", encoded),
    conn = conn
  )
  id <- if (is.list(result)) result$id %||% result else result
  if (is.null(id) || !nzchar(as.character(id)[1])) {
    stop(paste0("Could not resolve OneDev user id for '", user, "'."), call. = FALSE)
  }
  as.character(id)[1]
}

#' Query OneDev users
#'
#' Calls `GET /users`.
#'
#' @param query Optional OneDev user query string.
#' @param count Maximum number of results (default `100`).
#' @param offset Result offset (default `0`).
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of users (default), or a list when `as_tibble = FALSE`.
#' @family users
#' @examples
#' \dontrun{
#' od_query_users(count = 20L)
#' }
#' @export
od_query_users <- function(
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
    endpoint = "/users",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a single user
#'
#' @param user Login name or numeric user id.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @param use_internal_id If `TRUE`, treat `user` as the internal REST id.
#' @return Parsed user object (list).
#' @family users
#' @examples
#' \dontrun{
#' od_get_user("alice")
#' }
#' @export
od_get_user <- function(user, conn = NULL, use_internal_id = FALSE) {
  conn <- .od_conn(conn)
  user_id <- .od_resolve_entity_id(
    user,
    od_resolve_user_id,
    use_internal_id = use_internal_id,
    conn = conn
  )
  od_request("GET", paste0("/users/", user_id), conn = conn)
}

#' Get the authenticated user (`/users/me`)
#'
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed user object (list).
#' @family users
#' @examples
#' \dontrun{
#' od_get_me()
#' }
#' @export
od_get_me <- function(conn = NULL) {
  conn <- .od_conn(conn)
  od_request("GET", "/users/me", conn = conn)
}

#' Get email addresses for a user
#'
#' @param user Login name or numeric user id. Defaults to the authenticated user
#'   via [od_get_me()] when `NULL`.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of email addresses (default), or a list when
#'   `as_tibble = FALSE`.
#' @family users
#' @examples
#' \dontrun{
#' od_get_user_emails()
#' }
#' @export
od_get_user_emails <- function(user = NULL, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  user_id <- if (is.null(user) || !nzchar(as.character(user)[1])) {
    me <- od_get_me(conn = conn)
    as.character(me$id %||% "")[1]
  } else {
    od_resolve_user_id(user, conn = conn)
  }
  if (!nzchar(user_id)) {
    stop("Could not determine user id for email lookup.", call. = FALSE)
  }
  payload <- od_request(
    "GET",
    paste0("/users/", user_id, "/email-addresses"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' List SSH keys for a user
#'
#' Retrieves all SSH public keys registered for a user account.
#'
#' @param user Login name or numeric user id. Defaults to the authenticated user
#'   via [od_get_me()] when `NULL`.
#' @param as_tibble If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()].
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return A tibble of SSH keys (default), or a list when `as_tibble = FALSE`.
#' @family users
#' @examples
#' \dontrun{
#' od_list_user_ssh_keys()
#' }
#' @export
od_list_user_ssh_keys <- function(user = NULL, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  user_id <- if (is.null(user) || !nzchar(as.character(user)[1])) {
    me <- od_get_me(conn = conn)
    as.character(me$id %||% "")[1]
  } else {
    od_resolve_user_id(user, conn = conn)
  }
  if (!nzchar(user_id)) {
    stop("Could not determine user id for SSH key lookup.", call. = FALSE)
  }
  payload <- od_request(
    "GET",
    paste0("/users/", user_id, "/ssh-keys"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Add an SSH key to a user account
#'
#' Registers a new SSH public key for the authenticated or specified user.
#'
#' @param content SSH public key content (starting with `ssh-rsa`, `ssh-ed25519`, etc.).
#' @param name Optional name/description for the key (e.g., "My Laptop").
#' @param user Login name or numeric user id. Defaults to the authenticated user.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed SSH key object (list) with ID and fingerprint.
#' @family users
#' @examples
#' \dontrun{
#' od_add_user_ssh_key("ssh-rsa AAAA...", name = "Laptop")
#' }
#' @export
od_add_user_ssh_key <- function(content, name = NULL, user = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  content <- .od_coerce_string(content)
  .od_require(content, "content")

  user_id <- if (is.null(user) || !nzchar(as.character(user)[1])) {
    me <- od_get_me(conn = conn)
    as.character(me$id %||% "")[1]
  } else {
    od_resolve_user_id(user, conn = conn)
  }
  if (!nzchar(user_id)) {
    stop("Could not determine user id for SSH key registration.", call. = FALSE)
  }

  body <- list(content = content)
  if (!is.null(name) && nzchar(as.character(name)[1])) {
    body$name <- as.character(name)[1]
  }

  od_request(
    method = "POST",
    endpoint = paste0("/users/", user_id, "/ssh-keys"),
    body = body,
    conn = conn
  )
}

#' Delete an SSH key from a user account
#'
#' Removes an SSH public key from the authenticated or specified user.
#'
#' @param ssh_key_id Numeric SSH key ID.
#' @param user Login name or numeric user id. Defaults to the authenticated user.
#' @param conn Connection list from [od_get_config()] / [od_connection()].
#' @return Parsed API response (typically `NULL` on success).
#' @family users
#' @examples
#' \dontrun{
#' od_delete_user_ssh_key(1)
#' }
#' @export
od_delete_user_ssh_key <- function(ssh_key_id, user = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  ssh_key_id <- .od_coerce_string(ssh_key_id)
  .od_require(ssh_key_id, "ssh_key_id")

  user_id <- if (is.null(user) || !nzchar(as.character(user)[1])) {
    me <- od_get_me(conn = conn)
    as.character(me$id %||% "")[1]
  } else {
    od_resolve_user_id(user, conn = conn)
  }
  if (!nzchar(user_id)) {
    stop("Could not determine user id for SSH key deletion.", call. = FALSE)
  }

  od_request(
    method = "DELETE",
    endpoint = paste0("/users/", user_id, "/ssh-keys/", ssh_key_id),
    conn = conn
  )
}
