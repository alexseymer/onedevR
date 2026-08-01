#' Normalize a OneDev API collection payload to a list of items
#'
#' Accepts bare arrays, `{items: [...]}`, `{data: [...]}`, or a single object
#' with an `id` field.
#' @keywords internal
.od_normalize_collection <- function(response) {
  if (is.null(response)) {
    return(list())
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
