#' Query user groups
#'
#' Lists user groups in the OneDev instance.
#'
#' @param query {character} Optional OneDev group query string. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`). OneDev returns at most 100 per request; larger values are fetched in several requests.
#' @param offset {integer} Result offset (default `0`).
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of groups (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /groups
#' @family users
#' @examples
#' \dontrun{
#' od_query_groups(count = 20L)
#' }
#' @export
od_query_groups <- function(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
) {
  conn <- .od_conn(conn)
  query <- .od_coerce_string(query)
  payload <- .od_get_list(
    "/groups",
    query = if (nzchar(query)) query else NULL,
    count = count,
    offset = offset,
    conn = conn,
    request = od_request
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Resolve a group name to its numeric id
#'
#' A numeric value (or digits in a string) is taken as the id; a name is looked
#' up with `GET /groups/ids/{name}`.
#'
#' @noRd
.od_resolve_group_id <- function(group, conn = NULL, request = od_request) {
  group <- .od_coerce_string(group)
  .od_require(group, "group")
  if (grepl("^[0-9]+$", group)) {
    return(as.integer(group))
  }
  as.integer(request("GET", paste0("/groups/ids/", utils::URLencode(group, reserved = TRUE)), conn = conn))
}

#' Get a user group by name
#'
#' Retrieves details for a specific user group. The name is resolved to the
#' group id with `GET /groups/ids/{name}` first; a numeric id is used as is.
#'
#' @param name {character|numeric} Group name or numeric group id.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed group object (`id`, `name`, `description`, ...).
#' @endpoint GET /groups/{groupId}
#' @family users
#' @examples
#' \dontrun{
#' od_get_group("developers")
#' }
#' @export
od_get_group <- function(name, conn = NULL) {
  conn <- .od_conn(conn)
  group_id <- .od_resolve_group_id(name, conn = conn)
  od_request("GET", paste0("/groups/", group_id), conn = conn)
}

#' Add a user to a group
#'
#' **Experimental:** not yet verified against a live OneDev server (it changes
#' who has which permissions); the interface and behaviour may change.
#'
#' Creates a membership with `POST /memberships` (`userId`, `groupId`).
#'
#' @param group_name {character|numeric} Group name or numeric group id.
#' @param user {character|numeric} Login name or numeric user id.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {numeric} Id of the created membership.
#' @endpoint POST /memberships
#' @family users
#' @examples
#' \dontrun{
#' od_add_group_member("developers", "alice")
#' }
#' @export
od_add_group_member <- function(group_name, user, conn = NULL) {
  conn <- .od_conn(conn)
  group_id <- .od_resolve_group_id(group_name, conn = conn)
  user_id <- od_resolve_user_id(user, conn = conn)
  od_request(
    method = "POST",
    endpoint = "/memberships",
    body = list(userId = as.integer(user_id), groupId = group_id),
    conn = conn
  )
}

#' Remove a user from a group
#'
#' **Experimental:** not yet verified against a live OneDev server (it changes
#' who has which permissions); the interface and behaviour may change.
#'
#' Finds the membership of `user` in the group with
#' `GET /groups/{groupId}/memberships` and deletes it with
#' `DELETE /memberships/{membershipId}`. Fails if the user is not a member.
#'
#' @param group_name {character|numeric} Group name or numeric group id.
#' @param user {character|numeric} Login name or numeric user id.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response (typically `NULL` on success).
#' @endpoint DELETE /memberships/{membershipId}
#' @family users
#' @examples
#' \dontrun{
#' od_remove_group_member("developers", "alice")
#' }
#' @export
od_remove_group_member <- function(group_name, user, conn = NULL) {
  conn <- .od_conn(conn)
  group_id <- .od_resolve_group_id(group_name, conn = conn)
  user_id <- as.integer(od_resolve_user_id(user, conn = conn))
  memberships <- od_request("GET", paste0("/groups/", group_id, "/memberships"), conn = conn)
  hit <- Filter(function(m) identical(as.integer(m$userId %||% NA), user_id), memberships)
  if (!length(hit)) {
    stop(sprintf("User %s is not a member of group %s.", user_id, group_id), call. = FALSE)
  }
  od_request(
    method = "DELETE",
    endpoint = paste0("/memberships/", hit[[1]]$id),
    conn = conn
  )
}

#' List group memberships
#'
#' Retrieves the memberships of a user group with
#' `GET /groups/{groupId}/memberships`. Each row has the membership `id`, the
#' `userId` and the `groupId`; use [od_get_user()] for user details.
#'
#' @param group_name {character|numeric} Group name or numeric group id.
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of memberships (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /groups/{groupId}/memberships
#' @family users
#' @examples
#' \dontrun{
#' od_list_group_members("developers")
#' }
#' @export
od_list_group_members <- function(group_name, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  group_id <- .od_resolve_group_id(group_name, conn = conn)
  payload <- od_request("GET", paste0("/groups/", group_id, "/memberships"), conn = conn)
  od_as_tibble(payload, as_tibble = as_tibble)
}
