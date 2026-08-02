#' Try several request body shapes until one succeeds
#'
#' OneDev installations/versions accept different payload shapes for the same
#' endpoint (see `project_plan.md` sec 10). Tries each variant in order.
#'
#' @noRd
.od_request_with_variants <- function(method, endpoint, body_variants, conn = NULL) {
  last_error <- NULL
  for (body in body_variants) {
    outcome <- tryCatch(
      list(ok = TRUE, value = od_request(method, endpoint, body = body, conn = conn)),
      error = function(e) {
        last_error <<- e
        list(ok = FALSE, value = NULL)
      }
    )
    if (isTRUE(outcome$ok)) {
      return(outcome$value)
    }
  }
  if (is.null(last_error)) {
    stop("All request body variants failed with no error detail.", call. = FALSE)
  }
  stop(conditionMessage(last_error), call. = FALSE)
}
