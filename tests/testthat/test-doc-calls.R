# Code blocks in the README and vignettes must call exported od_*() functions
# with arguments they accept: no unknown argument names and no more positional
# arguments than the function has. A block that deliberately shows a wrong
# call marks it with the comment "# ERROR: unused argument" and is skipped.

doc_code_blocks <- function(file) {
  lines <- readLines(file, warn = FALSE)
  blocks <- list()
  buf <- NULL
  for (l in lines) {
    if (is.null(buf) && grepl("^\\s*```\\{?r", l)) {
      buf <- character()
    } else if (!is.null(buf) && grepl("^\\s*```\\s*$", l)) {
      blocks[[length(blocks) + 1L]] <- buf
      buf <- NULL
    } else if (!is.null(buf)) {
      buf <- c(buf, l)
    }
  }
  blocks
}

call_problems <- function(expr, exports, ns, file) {
  out <- character()
  walk <- function(e) {
    if (is.call(e)) {
      fn <- e[[1]]
      if (is.symbol(fn) && as.character(fn) %in% exports) {
        name <- as.character(fn)
        formal_names <- names(formals(get(name, envir = ns)))
        args <- as.list(e)[-1]
        arg_names <- names(args) %||% rep("", length(args))
        named <- arg_names[nzchar(arg_names)]
        if (!"..." %in% formal_names) {
          unknown <- named[is.na(pmatch(named, formal_names))]
          if (length(unknown)) {
            out <<- c(out, sprintf("%s: %s() has no argument %s", file, name, paste(unknown, collapse = ", ")))
          }
          free <- setdiff(formal_names, named)
          if (sum(!nzchar(arg_names)) > length(free)) {
            out <<- c(out, sprintf("%s: %s() called with too many positional arguments", file, name))
          }
        }
      }
      for (a in as.list(e)) if (!missing(a)) walk(a)
    }
  }
  walk(expr)
  out
}

test_that("documentation examples only use arguments that exist", {
  root <- testthat::test_path("..", "..")
  files <- c(
    file.path(root, "README.md"),
    list.files(file.path(root, "vignettes"), pattern = "\\.Rmd$", full.names = TRUE)
  )
  skip_if_not(all(file.exists(files)), "README and vignettes are not available in this check")

  ns <- asNamespace("onedevr")
  exports <- getNamespaceExports("onedevr")
  problems <- character()
  for (f in files) {
    for (block in doc_code_blocks(f)) {
      if (any(grepl("# ERROR: unused argument", block, fixed = TRUE))) next
      exprs <- tryCatch(parse(text = block, keep.source = FALSE), error = function(e) NULL)
      if (is.null(exprs)) {
        problems <- c(problems, sprintf("%s: a code block does not parse (starts: %s)", basename(f), substr(paste(block, collapse = " "), 1, 50)))
        next
      }
      for (e in exprs) problems <- c(problems, call_problems(e, exports, ns, basename(f)))
    }
  }
  expect_equal(problems, character(0))
})
