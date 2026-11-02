# Keep the user-facing version references in sync with DESCRIPTION.

pkg_version <- function() as.character(utils::packageVersion("onedevr"))

test_that("NEWS.md starts with the package version", {
  news <- testthat::test_path("..", "..", "NEWS.md")
  skip_if_not(file.exists(news), "NEWS.md is not available in this check")
  first <- grep("^# onedevr", readLines(news, warn = FALSE), value = TRUE)[1]
  expect_match(first, paste0("^# onedevr (", pkg_version(), "|\\(development\\))$"))
})

test_that("README names the current package version", {
  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md is not available in this check")
  expect_true(any(grepl(
    paste0("**v", pkg_version(), "**"),
    readLines(readme, warn = FALSE),
    fixed = TRUE
  )))
})
