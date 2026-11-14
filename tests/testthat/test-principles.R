# The Linux principle as tests: small, composable functions with plain data in
# and out, no captive interface, a small dependency budget. See the section
# "Leitprinzip" in project_plan.md and "Design principles" in CONTRIBUTING.md.
# A failing test here is a design decision to make deliberately: change the
# rule (and its documentation) or the code, but not silently.

exported_od <- function() {
  ex <- sort(getNamespaceExports("onedevr"))
  ex[grepl("^od_", ex)]
}

test_that("small is beautiful: the dependency budget is fixed", {
  imports <- utils::packageDescription("onedevr")$Imports
  imports <- trimws(sub("\\s*\\(.*$", "", strsplit(imports, ",")[[1]]))
  imports <- imports[nzchar(imports)]
  expect_setequal(
    imports,
    c("digest", "httr2", "jsonlite", "rlang", "tibble", "vctrs")
  )
})

test_that("compose: the object acted on comes first, conn is never a leading data argument", {
  # `conn` may be the first formal only when it is the only one (od_get_me(),
  # od_set_connection(), ...), so pipelines like `145 |> od_get_issue()` work.
  offenders <- character()
  for (f in exported_od()) {
    formal_names <- names(formals(get(f, envir = asNamespace("onedevr"))))
    if (length(formal_names) > 1L && formal_names[[1]] == "conn") {
      offenders <- c(offenders, f)
    }
  }
  expect_equal(offenders, character(0))
})

test_that("compose: every function that talks to OneDev accepts `conn`", {
  # Functions without `conn` are pure helpers, cache controls or connection
  # constructors. Adding to this list is a conscious design decision.
  allowed_without_conn <- c(
    "od_as_tibble", "od_clear_cache", "od_connection", "od_disable_cache",
    "od_enable_cache", "od_get_cache_stats", "od_get_config",
    "od_get_connection", "od_paginate", "od_with_cache"
  )
  without_conn <- character()
  for (f in exported_od()) {
    formal_names <- names(formals(get(f, envir = asNamespace("onedevr"))))
    if (!"conn" %in% formal_names) without_conn <- c(without_conn, f)
  }
  expect_equal(setdiff(without_conn, allowed_without_conn), character(0))
})

test_that("no captive interface: library code never prompts or writes to stdout", {
  # Data goes through return values, diagnostics through message()/conditions.
  forbidden <- c("readline", "menu", "askYesNo", "cat", "print")
  ns <- asNamespace("onedevr")
  offenders <- character()
  for (name in ls(ns, all.names = TRUE)) {
    f <- get(name, envir = ns)
    if (!is.function(f) || startsWith(name, "print.") || startsWith(name, "str.")) next
    used <- intersect(forbidden, all.names(body(f)))
    if (length(used)) offenders <- c(offenders, paste0(name, ": ", paste(used, collapse = ", ")))
  }
  expect_equal(offenders, character(0))
})

test_that("plain data interface: only the connection and errors are custom classes", {
  # Results are tibbles or plain lists. The package defines S3 methods for
  # exactly these classes.
  methods <- utils::getS3method("print", "od_connection", optional = TRUE)
  expect_true(is.function(methods))
  registered <- readLines(system.file("NAMESPACE", package = "onedevr"), warn = FALSE)
  s3 <- registered[grepl("^S3method\\(", registered)]
  classes <- unique(sub("^S3method\\([a-zA-Z_.]+,\\s*([a-zA-Z_.]+)\\)$", "\\1", s3))
  expect_setequal(classes, "od_connection")
})
