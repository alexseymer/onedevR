#!/usr/bin/env Rscript
# Narrow down HTTP 500 on POST /issue-comments.
#
# Posts a few short probe comments to ONE issue and reports, per probe, whether
# the call failed and whether a comment was created anyway. Use a scratch issue:
# the probes are real comments.
#
# Usage:
#   ONEDEV_CONFIRM_WRITES=1 Rscript scripts/diagnose-comments.R <issue-number>
#
# Reading the result:
#   all probes fail, none created   -> server-side problem unrelated to the text
#                                      (check the OneDev server log at the time
#                                      of the call: logs/server.log)
#   all probes fail, comments created -> the comment is saved, the response fails
#                                      (e.g. a notification step); not a data loss
#   only issue_ref / commit_ref fail -> references in the text trigger the error
#   only some probes fail            -> the text matters; compare the failing ones

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L) {
  stop("Usage: ONEDEV_CONFIRM_WRITES=1 Rscript scripts/diagnose-comments.R <issue-number>", call. = FALSE)
}
issue <- args[[1]]
if (!identical(Sys.getenv("ONEDEV_CONFIRM_WRITES"), "1")) {
  stop(
    "This posts probe comments to issue ", issue, ". Use a scratch issue and set ",
    "ONEDEV_CONFIRM_WRITES=1 to confirm.",
    call. = FALSE
  )
}

if (file.exists("DESCRIPTION") && requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(".", quiet = TRUE)
} else {
  library(onedevr)
}

probes <- list(
  plain = "onedevr diagnostic: plain text",
  markdown = "onedevr diagnostic: **bold** and `code`",
  issue_ref = sprintf("onedevr diagnostic: reference to #%s", issue),
  commit_ref = "onedevr diagnostic: commit 0123456789abcdef0123456789abcdef01234567"
)

count_comments <- function() length(od_get_issue_comments(issue, as_tibble = FALSE))

cat(sprintf("Issue %s: %d comments before\n\n", issue, count_comments()))
cat(sprintf("%-11s %-5s %-9s %s\n", "probe", "post", "created", "message"))
for (name in names(probes)) {
  before <- count_comments()
  result <- tryCatch(
    {
      od_add_issue_comment(issue, probes[[name]])
      "ok"
    },
    error = function(e) conditionMessage(e)
  )
  created <- count_comments() > before
  cat(sprintf(
    "%-11s %-5s %-9s %s\n",
    name,
    if (identical(result, "ok")) "OK" else "FAIL",
    if (created) "yes" else "no",
    if (identical(result, "ok")) "" else result
  ))
}
cat("\nSee the header of this script for how to read the table.\n")
