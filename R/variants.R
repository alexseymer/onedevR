#' Try several request body shapes until one succeeds
#'
#' OneDev installations/versions accept different payload shapes for the same
#' endpoint (see `project_plan.md` sec 10). Tries each variant in order.
#' When every variant fails, stops with all error messages (numbered), not only
#' the last — so an earlier structured-body failure is not hidden behind a
#' bare-string Jackson error.
#'
#' @noRd
.od_request_with_variants <- function(method, endpoint, body_variants, conn = NULL) {
  errors <- character(0)
  for (body in body_variants) {
    outcome <- tryCatch(
      list(ok = TRUE, value = od_request(method, endpoint, body = body, conn = conn)),
      error = function(e) {
        errors <<- c(errors, conditionMessage(e))
        list(ok = FALSE, value = NULL)
      }
    )
    if (isTRUE(outcome$ok)) {
      return(outcome$value)
    }
  }
  if (length(errors) == 0L) {
    stop("All request body variants failed with no error detail.", call. = FALSE)
  }
  if (length(errors) == 1L) {
    stop(errors[[1]], call. = FALSE)
  }
  numbered <- paste0(seq_along(errors), ". ", errors, collapse = "\n")
  stop(
    paste0("All request body variants failed:\n", numbered),
    call. = FALSE
  )
}
