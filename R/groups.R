#' Query user groups
#'
#' Lists user groups in the OneDev instance.
#'
#' @param query {character} Optional OneDev group query string. Default: `NULL`.
#' @param count {integer} Maximum number of results (default `100`).
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
  payload <- od_request(
    method = "GET",
    endpoint = "/groups",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}

#' Get a user group by name
#'
#' Retrieves details for a specific user group.
#'
#' @param name {character} Group name.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed group object.
#' @endpoint GET /groups/{groupName}
#' @family users
#' @examples
#' \dontrun{
#' od_get_group("developers")
#' }
#' @export
od_get_group <- function(name, conn = NULL) {
  conn <- .od_conn(conn)
  name <- .od_coerce_string(name)
  .od_require(name, "name")
  encoded <- utils::URLencode(name, reserved = TRUE)
  od_request(
    "GET",
    paste0("/groups/", encoded),
    conn = conn
  )
}

#' Add a user to a group
#'
#' Adds a user to the specified group's membership.
#'
#' @param group_name {character} Name of the group.
#' @param user {character|numeric} Login name or numeric user id.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response.
#' @endpoint POST /groups/{groupName}/members
#' @family users
#' @examples
#' \dontrun{
#' od_add_group_member("developers", "alice")
#' }
#' @export
od_add_group_member <- function(group_name, user, conn = NULL) {
  conn <- .od_conn(conn)
  group_name <- .od_coerce_string(group_name)
  .od_require(group_name, "group_name")
  user_id <- od_resolve_user_id(user, conn = conn)

  encoded_group <- utils::URLencode(group_name, reserved = TRUE)
  od_request(
    method = "POST",
    endpoint = paste0("/groups/", encoded_group, "/members"),
    body = list(userId = as.integer(user_id)),
    conn = conn
  )
}

#' Remove a user from a group
#'
#' Removes a user from the specified group's membership.
#'
#' @param group_name {character} Name of the group.
#' @param user {character|numeric} Login name or numeric user id.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {list} Parsed API response.
#' @endpoint DELETE /groups/{groupName}/members/{userId}
#' @family users
#' @examples
#' \dontrun{
#' od_remove_group_member("developers", "alice")
#' }
#' @export
od_remove_group_member <- function(group_name, user, conn = NULL) {
  conn <- .od_conn(conn)
  group_name <- .od_coerce_string(group_name)
  .od_require(group_name, "group_name")
  user_id <- od_resolve_user_id(user, conn = conn)

  encoded_group <- utils::URLencode(group_name, reserved = TRUE)
  od_request(
    method = "DELETE",
    endpoint = paste0("/groups/", encoded_group, "/members/", user_id),
    conn = conn
  )
}

#' List group members
#'
#' Retrieves all members of a user group.
#'
#' @param group_name {character} Name of the group.
#' @param as_tibble {logical} If `TRUE` (default via `options(onedevr.as_tibble)`), return
#'   a tibble via [od_as_tibble()]. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#' @return {tibble|list} A tibble of group members (default), or a list when `as_tibble = FALSE`.
#' @endpoint GET /groups/{groupName}/members
#' @family users
#' @examples
#' \dontrun{
#' od_list_group_members("developers")
#' }
#' @export
od_list_group_members <- function(group_name, as_tibble = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  group_name <- .od_coerce_string(group_name)
  .od_require(group_name, "group_name")

  encoded_group <- utils::URLencode(group_name, reserved = TRUE)
  payload <- od_request(
    "GET",
    paste0("/groups/", encoded_group, "/members"),
    conn = conn
  )
  od_as_tibble(payload, as_tibble = as_tibble)
}
