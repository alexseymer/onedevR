# Every od_*() call in the README and vignettes must name an exported function,
# so examples cannot silently drift from the API.

test_that("README and vignettes only call exported od_* functions", {
  root <- testthat::test_path("..", "..")
  docs <- c(
    file.path(root, "README.md"),
    list.files(file.path(root, "vignettes"), pattern = "\\.Rmd$", full.names = TRUE)
  )
  skip_if_not(all(file.exists(docs)), "README and vignettes are not available in this check")

  text <- paste(
    vapply(docs, function(f) paste(readLines(f, warn = FALSE), collapse = "\n"), character(1)),
    collapse = "\n"
  )
  called <- unique(regmatches(text, gregexpr("\\bod_[a-z_]+(?=\\()", text, perl = TRUE))[[1]])
  missing <- setdiff(called, getNamespaceExports("onedevr"))
  expect_equal(missing, character(0))
})
