.od_resolve_api_url <- function(endpoint, conn) {
  endpoint <- as.character(endpoint)[1]
  if (grepl("^https?://", endpoint)) {
    return(endpoint)
  }
  base <- conn$api_base_url %||% ""
  if (!nzchar(base)) {
    stop("No api_base_url in connection (set ONEDEV_HOST).", call. = FALSE)
  }
  paste0(sub("/+$", "", base), "/", sub("^/+", "", endpoint))
}

.od_prepare_request <- function(method, url, token, insecure_ssl = FALSE) {
  req <- httr2::request(url)
  req <- httr2::req_method(req, method)
  req <- httr2::req_headers(
    req,
    Authorization = paste("Bearer", token),
    Accept = "application/json"
  )
  req <- httr2::req_timeout(req, 30)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  if (isTRUE(insecure_ssl)) {
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

.od_http_error <- function(response, payload) {
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
  msg <- as.character(msg)[1]
  stop(
    sprintf(
      "OneDev API request failed [HTTP %d]%s",
      status,
      if (nzchar(msg)) paste0(": ", msg) else ""
    ),
    call. = FALSE
  )
}

#' Low-level OneDev REST request
#'
#' Escape hatch for any `/~api/...` endpoint. Prefer high-level `od_*`
#' helpers when they exist.
#'
#' @param method HTTP method (default `"GET"`).
#' @param endpoint API path (e.g. `"/issues"`) or absolute URL.
#' @param query Named list of query parameters (NULLs dropped).
#' @param body Request body; JSON-encoded with `jsonlite::toJSON()`.
#' @param conn Connection list from [od_get_config()] (or compatible).
#'
#' @return Parsed JSON payload (list), or `NULL` for empty bodies.
#' @export
od_request <- function(method = "GET", endpoint, query = NULL, body = NULL, conn = NULL) {
  conn <- conn %||% od_get_config()
  method <- toupper(trimws(as.character(method)[1]))
  url <- .od_resolve_api_url(endpoint, conn)
  req <- .od_prepare_request(method, url, conn$token, conn$insecure_ssl)

  if (length(query) > 0) {
    query <- query[!vapply(query, is.null, logical(1))]
    if (length(query) > 0) {
      req <- do.call(httr2::req_url_query, c(list(req), query))
    }
  }

  if (!is.null(body)) {
    json_body <- jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")
    req <- httr2::req_headers(req, "Content-Type" = "application/json")
    req <- httr2::req_body_raw(req, charToRaw(enc2utf8(as.character(json_body))))
  }

  response <- httr2::req_perform(req)
  payload <- .od_parse_response_body(response)
  if (httr2::resp_status(response) >= 400L) {
    .od_http_error(response, payload)
  }

  payload
}
