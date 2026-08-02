#' Normalize a OneDev API collection payload to a list of items
#'
#' Accepts bare arrays, `{items: [...]}`, `{data: [...]}`, or a single object
#' with an `id` field.
#' @keywords internal
.od_normalize_collection <- function(response) {
  if (is.null(response)) {
    return(list())
  }
  # Already a tibble/data.frame from od_as_tibble() — treat as rows.
  if (inherits(response, "data.frame")) {
    if (!nrow(response)) {
      return(list())
    }
    return(lapply(seq_len(nrow(response)), function(i) {
      as.list(response[i, , drop = FALSE])
    }))
  }
  if (is.list(response) && !is.null(response$items) && is.list(response$items)) {
    return(response$items)
  }
  if (is.list(response) && !is.null(response$data) && is.list(response$data)) {
    return(response$data)
  }
  if (is.list(response) && !is.null(names(response)) && "id" %in% names(response)) {
    return(list(response))
  }
  if (is.list(response)) {
    return(response)
  }
  list(response)
}

#' Default for tibble conversion of list endpoints
#' @keywords internal
.od_as_tibble_default <- function(as_tibble = NULL) {
  if (is.null(as_tibble)) {
    getOption("onedevr.as_tibble", TRUE)
  } else {
    isTRUE(as_tibble)
  }
}

#' Convert a OneDev collection payload to a tibble
#'
#' Flattens list-of-objects responses (from [od_query_issues()], etc.) into a
#' [tibble::tibble()]. Nested objects become list-columns. Pass
#' `as_tibble = FALSE` to get the raw list of items instead.
#'
#' The package default is controlled by `options(onedevr.as_tibble = TRUE)`.
#'
#' @param response Parsed API response (list).
#' @param as_tibble If `TRUE`, return a tibble; if `FALSE`, a list of items.
#'   Default: `getOption("onedevr.as_tibble", TRUE)`.
#' @return A tibble, or a list when `as_tibble = FALSE`.
#' @export
od_as_tibble <- function(response, as_tibble = NULL) {
  items <- .od_normalize_collection(response)
  if (!.od_as_tibble_default(as_tibble)) {
    return(items)
  }

  if (!length(items)) {
    return(tibble::tibble())
  }

  # Round-trip via JSON so nested objects become list-columns / nested tibbles
  # consistently across OneDev payload shapes.
  df <- tryCatch(
    jsonlite::fromJSON(
      jsonlite::toJSON(items, auto_unbox = TRUE, null = "null"),
      simplifyDataFrame = TRUE,
      flatten = FALSE
    ),
    error = function(e) NULL
  )

  if (is.null(df)) {
    return(tibble::tibble(value = items))
  }
  tibble::as_tibble(df)
}
