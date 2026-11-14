.od_origin <- function(url) {
  tolower(sub("^(https?://[^/?#]+).*$", "\\1", as.character(url)[1], ignore.case = TRUE))
}

.od_resolve_api_url <- function(endpoint, conn) {
  endpoint <- as.character(endpoint)[1]
  if (grepl("^https?://", endpoint, ignore.case = TRUE)) {
    # Credentials are attached to every request, so only the configured
    # OneDev origin may receive them.
    host <- conn$host %||% ""
    if (!nzchar(host) || !identical(.od_origin(endpoint), .od_origin(host))) {
      stop(
        "Absolute endpoint URLs must use the configured OneDev host (",
        if (nzchar(host)) .od_origin(host) else "not set",
        "); refusing to send credentials elsewhere.",
        call. = FALSE
      )
    }
    return(endpoint)
  }
  base <- conn$api_base_url %||% ""
  if (!nzchar(base)) {
    stop("No api_base_url in connection (set ONEDEV_HOST).", call. = FALSE)
  }
  paste0(sub("/+$", "", base), "/", sub("^/+", "", endpoint))
}

.od_warn_insecure_once <- function() {
  if (isTRUE(.onedevr_env$insecure_warned)) {
    return(invisible(FALSE))
  }
  .onedevr_env$insecure_warned <- TRUE
  warning(
    "TLS certificate verification is disabled (insecure_ssl / ONEDEV_CURL_INSECURE). ",
    "Credentials can be intercepted; use this only on networks you trust.",
    call. = FALSE
  )
  invisible(TRUE)
}

.od_prepare_request <- function(method, url, conn, accept = "application/json") {
  req <- httr2::request(url)
  req <- httr2::req_method(req, method)
  req <- httr2::req_headers(req, Accept = accept)
  req <- httr2::req_timeout(req, 30)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  auth <- tolower(conn$auth %||% "bearer")
  if (identical(auth, "basic")) {
    user <- conn$username %||% ""
    pass <- .od_first_non_empty(conn$password %||% "", conn$token %||% "")
    req <- httr2::req_auth_basic(req, user, pass)
  } else {
    req <- httr2::req_headers(
      req,
      Authorization = paste("Bearer", conn$token %||% "")
    )
  }

  if (isTRUE(conn$insecure_ssl)) {
    .od_warn_insecure_once()
    req <- httr2::req_options(req, ssl_verifypeer = 0L, ssl_verifyhost = 0L)
  }

  req
}

.od_parse_response_body <- function(response) {
  txt <- tryCatch(httr2::resp_body_string(response), error = function(e) "")
  if (!nzchar(txt)) {
    return(NULL)
  }
  tryCatch(
    jsonlite::fromJSON(txt, simplifyVector = FALSE),
    error = function(e) txt
  )
}

.od_clean_error_message <- function(msg, max_chars = 300L) {
  msg <- as.character(msg)[1]
  if (is.na(msg)) {
    return("")
  }
  if (grepl("<\\s*(html|!doctype|body)", msg, ignore.case = TRUE)) {
    m <- regmatches(msg, regexec("<title[^>]*>([^<]*)</title>", msg, ignore.case = TRUE))[[1]]
    title <- if (length(m) == 2L) trimws(m[[2]]) else ""
    msg <- if (nzchar(title)) {
      paste0("HTML error page: ", title)
    } else {
      trimws(gsub("\\s+", " ", gsub("<[^>]+>", " ", msg)))
    }
  }
  if (nchar(msg) > max_chars) {
    msg <- paste0(substr(msg, 1L, max_chars), "...")
  }
  msg
}

# Signals an `od_http_error` condition (also an `error`): the message is the
# usual "OneDev API request failed [HTTP n]: ..." text, and the fields
# `status`, `method` and `url` let callers react without parsing the text.
.od_http_error <- function(response, payload, method = NULL) {
  status <- httr2::resp_status(response)
  msg <- ""
  if (is.list(payload)) {
    msg <- payload$message %||% payload$error %||% payload$title %||% ""
    if (is.list(msg)) {
      msg <- paste(unlist(msg), collapse = "; ")
    }
  } else if (is.character(payload) && length(payload) == 1L) {
    msg <- payload
  }
  msg <- .od_clean_error_message(msg)
  if (status == 406L && grepl("Count should not be greater than", msg, fixed = TRUE)) {
    msg <- paste0(
      msg,
      " (use the list helpers, which page automatically, or fetch further",
      " pages with `offset` / od_paginate())"
    )
  }
  if (status == 406L && grepl("Invalid query", msg, fixed = TRUE)) {
    msg <- paste0(
      msg,
      " (hint: use fuzzy text like ~text~ instead of \"Title\" contains, check",
      " state names on the project's board, and see",
      " od_get_query_description(\"issue\"))"
    )
  }
  rlang::abort(
    sprintf(
      "OneDev API request failed [HTTP %d]%s",
      status,
      if (nzchar(msg)) paste0(": ", msg) else ""
    ),
    class = "od_http_error",
    status = status,
    method = method,
    url = tryCatch(httr2::resp_url(response), error = function(e) NA_character_),
    call = NULL
  )
}

# OneDev rejects `count` values above 100 with HTTP 406.
.od_max_count <- 100L

#' GET a list endpoint, paging transparently when `count` exceeds the server limit
#'
#' Fetches `count` records starting at `offset` in pages of at most 100. A
#' request for 100 or fewer records is a single call with the original `count`
#' and `offset`. `request` is `od_request` by default; callers pass their own
#' binding so tests can stub it.
#'
#' @param endpoint {character} List endpoint, e.g. `"/issues"`.
#' @param query {character} Optional OneDev query string (`NULL` to omit).
#' @param count {integer} Number of records wanted.
#' @param offset {integer} Offset of the first record.
#' @param conn {list} Connection list.
#' @param request {function} Request function (default [od_request()]).
#' @return {list} Concatenated records.
#' @noRd
.od_get_list <- function(endpoint, query = NULL, count = 100L, offset = 0L, conn = NULL, request = od_request) {
  count <- as.integer(count)
  offset <- as.integer(offset)
  if (length(count) != 1L || is.na(count) || count < 1L) {
    stop("`count` must be a positive integer.", call. = FALSE)
  }
  if (length(offset) != 1L || is.na(offset) || offset < 0L) {
    stop("`offset` must be a non-negative integer.", call. = FALSE)
  }
  out <- list()
  repeat {
    n <- min(.od_max_count, count - length(out))
    page <- request(
      method = "GET",
      endpoint = endpoint,
      query = list(query = query, count = n, offset = offset + length(out)),
      conn = conn
    )
    if (!is.list(page)) {
      return(page)
    }
    out <- c(out, page)
    if (length(page) < n || length(out) >= count) {
      break
    }
  }
  out
}

#' Low-level OneDev REST request
#'
#' Escape hatch for any `/~api/...` endpoint. Prefer high-level `od_*`
#' helpers when they exist.
#'
#' @param method {character} HTTP method (default `"GET"`). Default: `"GET"`.
#' @param endpoint {character} API path (e.g. `"/issues"`) or absolute URL.
#' @param query {list} Named list of query parameters (NULLs dropped). Default: `NULL`.
#' @param body {list} Request body; JSON-encoded with `jsonlite::toJSON()`. Default: `NULL`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {list} Parsed JSON payload, or `NULL` for empty bodies.
#'
#' @section Errors:
#' An HTTP status of 400 or above signals a condition of class `od_http_error`
#' (also an `error`) with the fields `status`, `method` and `url`. Test it with
#' `inherits(e, "od_http_error")` and branch on `e$status` instead of parsing
#' the message.
#'
#' @family utilities
#' @examples
#' \dontrun{
#' od_request("GET", "/projects")
#' tryCatch(
#'   od_request("GET", "/issues/0"),
#'   od_http_error = function(e) e$status
#' )
#' }
#' @export
od_request <- function(method = "GET", endpoint, query = NULL, body = NULL, conn = NULL) {
  conn <- .od_conn(conn)
  method <- toupper(.od_coerce_string(method))
  url <- .od_resolve_api_url(endpoint, conn)
  req <- .od_prepare_request(method, url, conn)

  if (length(query) > 0) {
    query <- query[!vapply(query, is.null, logical(1))]
    if (length(query) > 0) {
      req <- rlang::exec(httr2::req_url_query, req, !!!query, .multi = "explode")
    }
  }

  if (!is.null(body)) {
    json_body <- jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")
    req <- httr2::req_headers(req, "Content-Type" = "application/json")
    req <- httr2::req_body_raw(req, charToRaw(enc2utf8(as.character(json_body))))
  }

  # Cache only GET requests, and only when od_enable_cache() is on. The key
  # is partitioned by credentials so accounts never share cached responses.
  use_cache <- identical(method, "GET") &&
    isTRUE(.onedevr_cache_env$cache_options$enabled)
  if (use_cache) {
    cache_partition <- .od_cache_partition(conn)
    cache_key <- .od_make_cache_key(url, method, query, body, conn_host = cache_partition)
    cached <- .od_get_from_cache(cache_key, url, method, conn_host = cache_partition)
    if (!is.null(cached)) {
      return(cached)
    }
  }

  response <- httr2::req_perform(req)
  payload <- .od_parse_response_body(response)
  if (httr2::resp_status(response) >= 400L) {
    .od_http_error(response, payload, method = method)
  }

  if (use_cache) {
    .od_put_in_cache(cache_key, payload, url, method, conn_host = cache_partition)
  }

  payload
}

#' Low-level OneDev request returning raw bytes
#'
#' Used for non-JSON endpoints such as streaming build logs
#' (`Accept: */*`). Prefer [od_request()] for normal JSON APIs.
#'
#' @inheritParams od_request
#' @param accept HTTP Accept header (default `"*/*"`).
#' @param timeout Request timeout in seconds (default `60`).
#' @return Raw vector of the response body.
#' @noRd
.od_request_raw <- function(
  method = "GET",
  endpoint,
  query = NULL,
  body = NULL,
  conn = NULL,
  accept = "*/*",
  timeout = 60
) {
  conn <- .od_conn(conn)
  method <- toupper(.od_coerce_string(method))
  url <- .od_resolve_api_url(endpoint, conn)
  req <- .od_prepare_request(method, url, conn, accept = accept)
  req <- httr2::req_timeout(req, as.numeric(timeout)[1])

  if (length(query) > 0) {
    query <- query[!vapply(query, is.null, logical(1))]
    if (length(query) > 0) {
      req <- rlang::exec(httr2::req_url_query, req, !!!query, .multi = "explode")
    }
  }

  if (!is.null(body)) {
    json_body <- jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")
    req <- httr2::req_headers(req, "Content-Type" = "application/json")
    req <- httr2::req_body_raw(req, charToRaw(enc2utf8(as.character(json_body))))
  }

  response <- httr2::req_perform(req)
  if (httr2::resp_status(response) >= 400L) {
    payload <- .od_parse_response_body(response)
    .od_http_error(response, payload, method = method)
  }

  httr2::resp_body_raw(response)
}
