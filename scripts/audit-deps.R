#!/usr/bin/env Rscript
# Check the package's R dependencies against the OSV vulnerability database
# (https://osv.dev, CRAN ecosystem; includes the R Consortium advisories).
#
# Two checks per dependency in Depends/Imports/Suggests:
#   installed  the version resolved on this machine (what users get today)
#   minimum    the lowest version DESCRIPTION still allows (`pkg (>= x.y.z)`)
# Exit status 1 if any of them is affected by a published advisory, so CI fails
# until the dependency is updated or the minimum version is raised.
#
# Usage: Rscript scripts/audit-deps.R [path/to/DESCRIPTION]

args <- commandArgs(trailingOnly = TRUE)
desc_path <- if (length(args) >= 1L) args[[1]] else "DESCRIPTION"

parse_deps <- function(desc_path) {
  d <- read.dcf(desc_path)
  fields <- intersect(c("Depends", "Imports", "Suggests"), colnames(d))
  out <- list()
  for (f in fields) {
    items <- trimws(strsplit(d[1, f], ",")[[1]])
    items <- items[nzchar(items)]
    for (it in items) {
      name <- trimws(sub("\\(.*$", "", it))
      if (identical(name, "R")) next
      min_ver <- NA_character_
      m <- regmatches(it, regexec("\\(\\s*>=\\s*([0-9][0-9.-]*)\\s*\\)", it))[[1]]
      if (length(m) == 2L) min_ver <- m[[2]]
      out[[length(out) + 1L]] <- list(package = name, field = f, minimum = min_ver)
    }
  }
  out
}

osv_batch <- function(queries) {
  body <- list(queries = lapply(queries, function(q) {
    list(package = list(name = q$package, ecosystem = "CRAN"), version = q$version)
  }))
  req <- httr2::request("https://api.osv.dev/v1/querybatch")
  req <- httr2::req_body_json(req, body, auto_unbox = TRUE)
  req <- httr2::req_retry(req, max_tries = 3)
  req <- httr2::req_timeout(req, 60)
  resp <- httr2::req_perform(req)
  httr2::resp_body_json(resp)$results
}

osv_summary <- function(id) {
  tryCatch(
    {
      resp <- httr2::req_perform(httr2::request(paste0("https://api.osv.dev/v1/vulns/", id)))
      v <- httr2::resp_body_json(resp)
      v$summary %||% substr(v$details %||% "", 1, 120)
    },
    error = function(e) ""
  )
}

`%||%` <- function(a, b) if (is.null(a)) b else a

deps <- parse_deps(desc_path)
queries <- list()
for (d in deps) {
  inst <- tryCatch(as.character(utils::packageVersion(d$package)), error = function(e) NA_character_)
  if (!is.na(inst)) {
    queries[[length(queries) + 1L]] <- list(package = d$package, version = inst, kind = "installed", field = d$field)
  }
  if (!is.na(d$minimum)) {
    queries[[length(queries) + 1L]] <- list(package = d$package, version = d$minimum, kind = "minimum", field = d$field)
  }
}

cat(sprintf("Auditing %d dependency versions against OSV (CRAN)...\n", length(queries)))
results <- osv_batch(queries)

found <- 0L
for (i in seq_along(queries)) {
  q <- queries[[i]]
  vulns <- results[[i]]$vulns
  if (length(vulns) == 0L) next
  for (v in vulns) {
    found <- found + 1L
    cat(sprintf(
      "VULNERABLE  %-10s %-9s %s %s  https://osv.dev/%s\n    %s\n",
      q$kind, q$field, q$package, q$version, v$id, osv_summary(v$id)
    ))
  }
}

if (found > 0L) {
  cat(sprintf("\n%d advisory match(es). Update the dependency or raise the minimum version in DESCRIPTION.\n", found))
  quit(status = 1L)
}
cat("No known vulnerabilities in installed or minimum dependency versions.\n")
