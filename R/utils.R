.od_trim_env <- function(name) {
  trimws(as.character(Sys.getenv(name, unset = ""))[1])
}

.od_first_non_empty <- function(...) {
  vals <- c(...)
  for (v in vals) {
    v <- trimws(as.character(v)[1])
    if (nzchar(v)) {
      return(v)
    }
  }
  ""
}

.od_parse_flag <- function(x) {
  x <- tolower(trimws(as.character(x)[1]))
  x %in% c("1", "true", "yes", "on")
}

#' Derive a OneDev project path from a git remote URL
#' @noRd
.od_derive_project_path <- function(repo_url) {
  repo_url <- trimws(as.character(repo_url)[1])
  if (!nzchar(repo_url)) {
    return("")
  }
  path <- sub("^https?://[^/]+/", "", repo_url, perl = TRUE)
  path <- sub("\\.git/?$", "", path, perl = TRUE)
  path <- sub("^/+", "", path, perl = TRUE)
  trimws(path)
}

#' Strip a leading `#` from a UI issue/build number
#' @noRd
.od_strip_hash <- function(x) {
  gsub("^#", "", trimws(as.character(x)[1]), perl = TRUE)
}
