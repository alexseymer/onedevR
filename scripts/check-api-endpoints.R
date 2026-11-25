#!/usr/bin/env Rscript
# Compare the endpoints documented in the package (`@endpoint` tags in R/*.R)
# with the REST API description of a live OneDev instance (`/~api/help`).
#
# Read-only: only GET requests to the help pages. Needs ONEDEV_HOST and a token
# as for the live tests.
#
# Usage:
#   Rscript scripts/check-api-endpoints.R
#
# Exit status 1 if a documented endpoint is neither on the instance nor in the
# list of endpoints known to be missing there. Update `known_unlisted` (and the
# "Availability" note in the roxygen text) when an instance offers one.

known_unlisted <- c(
  "POST /issues/{}/pull-requests", "DELETE /issues/{}/pull-requests/{}",
  "GET /projects/{}/webhooks/{}",
  "POST /projects/{}/webhooks", "DELETE /projects/{}/webhooks/{}",
  "POST /repositories/{}/commits/{}/statuses", "GET /repositories/{}/commits/{}/statuses",
  "POST /builds/{}/promotions"
)

if (file.exists("DESCRIPTION") && requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(".", quiet = TRUE)
} else {
  library(onedevr)
}
conn <- od_get_config()

help_json <- function(path) {
  req <- httr2::request(paste0(sub("/+$", "", conn$host), path))
  req <- httr2::req_headers(req, Authorization = paste("Bearer", conn$token), Accept = "application/json")
  req <- httr2::req_error(req, is_error = function(r) FALSE)
  resp <- httr2::req_perform(req)
  if (httr2::resp_status(resp) != 200L) {
    stop("GET ", path, " answered HTTP ", httr2::resp_status(resp), call. = FALSE)
  }
  jsonlite::fromJSON(httr2::resp_body_string(resp), simplifyVector = FALSE)
}
norm <- function(p) sub("/+$", "", gsub("\\{[^}]*\\}", "{}", sub("^/~api", "", p)))

instance <- character()
for (res in help_json("/~api/help")$resources) {
  for (m in help_json(res$help)$methods) {
    instance <- c(instance, paste(m$httpMethod, norm(m$path)))
  }
}
instance <- unique(instance)

src <- list.files("R", pattern = "[.]R$", full.names = TRUE)
rows <- list()
for (f in src) {
  lines <- readLines(f, warn = FALSE)
  pending <- list()
  for (l in lines) {
    m <- regmatches(l, regexec("^#\\x27 @endpoint (GET|POST|PUT|DELETE|PATCH) (\\S+)", l))[[1]]
    if (length(m)) pending[[length(pending) + 1L]] <- c(m[[2]], m[[3]])
    fn <- regmatches(l, regexec("^(od_\\S+) <- function", l))[[1]]
    if (length(fn)) {
      for (p in pending) rows[[length(rows) + 1L]] <- data.frame(fn = fn[[2]], endpoint = paste(p[[1]], norm(p[[2]])))
      pending <- list()
    }
  }
}
rows <- do.call(rbind, rows)
rows$on_instance <- rows$endpoint %in% instance
rows$known <- rows$endpoint %in% known_unlisted

cat(sprintf("Instance lists %d endpoints; the package documents %d.\n", length(instance), nrow(rows)))
unexpected <- rows[!rows$on_instance & !rows$known, ]
if (nrow(unexpected)) {
  cat("\nDocumented but NOT on the instance (unexpected):\n")
  print(unexpected[, c("fn", "endpoint")], row.names = FALSE)
}
now_listed <- rows[rows$on_instance & rows$known, ]
if (nrow(now_listed)) {
  cat("\nListed on the instance although marked unavailable (update the notes):\n")
  print(now_listed[, c("fn", "endpoint")], row.names = FALSE)
}
cat(sprintf("\nKnown unavailable on this instance: %d function(s).\n", sum(!rows$on_instance & rows$known)))
if (nrow(unexpected)) quit(status = 1L)
cat("OK: every other documented endpoint exists.\n")
