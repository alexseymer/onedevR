# Contributing to onedevR

Thank you for your interest in contributing to onedevR! This guide will
help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Style Guide](#style-guide)
- [Questions or Need Help?](#questions-or-need-help)

## Code of Conduct

Be respectful and constructive in all interactions. We follow the
[Contributor Covenant Code of
Conduct](https://www.contributor-covenant.org/).

## Getting Started

### Prerequisites

- R 4.0+ (4.1+ recommended)
- Git
- A GitHub account

### Setup Development Environment

1.  **Fork the repository** on GitHub

2.  **Clone your fork:**

    ``` bash
    git clone https://github.com/YOUR-USERNAME/onedevR.git
    cd onedevR
    ```

3.  **Install dependencies:**

    ``` r

    # In R
    devtools::install_deps(dependencies = TRUE)
    ```

4.  **Create a development branch:**

    ``` bash
    git checkout -b feature/your-feature-name
    ```

### Project Structure

    onedevR/
    ├── R/                      # R source files
    │   ├── config.R           # Configuration helpers
    │   ├── connection.R       # Connection management
    │   ├── issues.R           # Issue operations
    │   ├── builds.R           # Build operations
    │   ├── pull_requests.R    # PR operations
    │   ├── repository.R       # Repository operations
    │   └── ...                # Additional modules
    ├── man/                   # Auto-generated roxygen2 docs
    ├── tests/testthat/        # Test files
    ├── vignettes/             # Package vignettes/guides
    ├── DESCRIPTION            # Package metadata
    ├── NAMESPACE              # Namespace configuration
    └── README.md              # Project overview

## Making Changes

### Adding a New Function

1.  **Create function in appropriate R file** (or new file if it’s a new
    module)

2.  **Add roxygen2 documentation:**

    ``` r

    #' Get issue details
    #'
    #' Fetch detailed information for a specific issue.
    #'
    #' @param issue_number UI issue number (e.g., 145 for #145)
    #' @param conn Connection object. If NULL, uses default connection.
    #'
    #' @return List with issue details
    #'
    #' @examples
    #' \dontrun{
    #'   issue <- od_get_issue(145)
    #' }
    #'
    #' @export
    od_get_issue <- function(issue_number, conn = NULL) {
      # Implementation
    }
    ```

3.  **Generate documentation:**

    ``` r

    devtools::document()
    ```

4.  **Write tests** (see [Testing](#testing) section)

5.  **Test with live instance** (optional but recommended)

### Modifying Existing Functions

1.  Update function code and roxygen2 comments
2.  Run `devtools::document()`
3.  Update/add tests
4.  Verify no other functions break (run full test suite)

### Naming Conventions

- **Function names:** `od_action_noun()` (e.g.,
  [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md),
  [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md))
- **Internal functions:** Prefix with `.od_` (not exported)
- **Variables:** `snake_case`
- **Constants:** `UPPER_SNAKE_CASE`

### Internal Helper Functions

The package includes shared internal helpers to reduce duplication and
maintain consistency:

#### `.od_coerce_string(x, trim = TRUE, default = "")`

Normalizes string values with optional trimming and defaults.
Consolidates the repeated pattern:

``` r

trimws(as.character(x %||% default)[1])
```

**Usage:**

``` r

param <- .od_coerce_string(user_input)  # Trim + default to ""
name <- .od_coerce_string(name, default = "Unnamed")
value <- .od_coerce_string(value, trim = FALSE)  # No trimming
```

#### `.od_resolve_entity_id(number, resolver_fn, use_internal_id = FALSE, conn = NULL)`

Resolves UI numbers (e.g., `#100`) to internal REST IDs. Handles both: -
Direct numeric/string IDs (returned as-is) - UI numbers requiring
resolution via an API call

**Usage:**

``` r

issue_id <- .od_resolve_entity_id(145, od_resolve_issue_id, conn = conn)
build_id <- .od_resolve_entity_id(
  build_number,
  od_resolve_build_id,
  use_internal_id = use_internal_id,
  conn = conn
)
```

#### `.od_require(x, name)`

Validates that a parameter is non-empty; stops with a clear error if
not.

``` r

.od_require(job_name, "job_name")  # Stops if job_name is ""
.od_require(branch, "branch")
```

**Usage pattern:**

``` r

branch <- .od_coerce_string(branch)
.od_require(branch, "branch")
```

Other helpers (in `utils.R`): - `.od_trim_env()` — Trim environment
variables - `.od_first_non_empty()` — Return first non-empty value from
list - `.od_parse_flag()` — Parse boolean string flags -
`.od_derive_project_path()` — Extract path from git remote URL -
`.od_strip_hash()` — Remove leading `#` from UI numbers

### OneDev API Reference

Always check the [OneDev API documentation](https://onedev.io/~help/api)
when:

- Adding new endpoints
- Changing request structure
- Adding query parameters

Key references: - `tod` CLI: <https://github.com/theonedev/tod> - OneDeV
API: `https://your-onedev-host/~help/api`

## Testing

### Running Tests

``` r

# Run all tests
devtools::test()

# Run specific test file
devtools::test_file("tests/testthat/test-issues.R")

# Run tests with coverage
devtools::test_coverage()
```

### Writing Tests

Create test files in `tests/testthat/` following the pattern `test-*.R`:

``` r

# tests/testthat/test-issues.R
test_that("od_get_issue returns a list", {
  # Mock the API response
  mock_response <- list(
    number = 145,
    title = "Test issue",
    state = "Open"
  )
  
  # Mock the internal request function
  with_mock(
    `.od_request()` = mock_response,
    {
      result <- od_get_issue(145)
      expect_is(result, "list")
      expect_equal(result$number, 145)
    }
  )
})
```

**Test Coverage Goals:** - Aim for \>80% line coverage - Include happy
path, error cases, and edge cases - Use mocks for API calls (no live API
calls in tests)

### Mocking API Responses

onedevr uses `mockery` for test mocks:

``` r

# Stub od_request to return test data
stub_request <- function(method, endpoint, ...) {
  list(id = 1, title = "Mocked")
}

test_that("query uses pagination", {
  with_mock(
    `onedevr::od_request` = stub_request,
    {
      result <- od_query_issues(state = "Open")
      expect_true(nrow(result) > 0)
    }
  )
})
```

## Documentation

### Vignettes

Add/update vignettes for: - New major features - Complex workflows -
Integration examples

Vignettes go in `vignettes/`:

``` r
# vignettes/new-feature.Rmd
---
title: "New Feature Guide"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{New Feature}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

# Overview
...
```

Build and preview:

``` r

devtools::build_vignettes()
```

### Roxygen2 Documentation

Always include: - `@param` for each parameter - `@return` describing
return value - `@examples` with `\dontrun{}` for interactive examples -
`@export` for public functions - `@keywords internal` for internal
functions

Example:

``` r

#' Query issues with filters
#'
#' @param state Issue state filter (e.g., "Open", "Closed")
#' @param count Maximum results to return (default: 50)
#' @param as_tibble Return as tibble? (default: TRUE)
#' @param conn Connection object (default: NULL, uses default)
#'
#' @return Tibble or list of issues
#'
#' @examples
#' \dontrun{
#'   open <- od_query_issues(state = "Open")
#'   open %>%
#'     filter(priority == "High")
#' }
#'
#' @export
od_query_issues <- function(state, count = 50L, 
                            as_tibble = TRUE, conn = NULL) {
  # ...
}
```

## Submitting Changes

### Before You Push

1.  **Verify code quality:**

    ``` r

    devtools::check()      # Full R CMD check
    devtools::test()       # Run tests
    devtools::spell_check() # Check spelling
    ```

2.  **Format code** (optional but appreciated):

    ``` bash
    # Using styler
    Rscript -e 'styler::style_pkg()'
    ```

3.  **Update NEWS.md** with your changes:

    ``` markdown
    ## Version 0.6.0 (Unreleased)

    ### New Features
    - `od_new_function()` for X operation (#issue-number)

    ### Bug Fixes
    - Fixed Y bug in `od_existing_function()` (#issue-number)
    ```

### Create a Pull Request

1.  **Push your branch:**

    ``` bash
    git push origin feature/your-feature-name
    ```

2.  **Open PR on GitHub:**

    - Reference any related issues
    - Describe what your change does
    - Note if it’s a breaking change

3.  **PR Template:**

    ``` markdown
    ## Description
    Brief description of the change

    ## Type of Change
    - [ ] New feature
    - [ ] Bug fix
    - [ ] Documentation
    - [ ] Test improvement

    ## Testing
    How did you test this?

    ## Related Issues
    Fixes #issue-number
    ```

### Review Process

- At least one maintainer review required
- All tests must pass
- Coverage should remain \>80%
- Documentation should be updated

## Style Guide

### R Code Style

Follow the [Tidyverse style guide](https://style.tidyverse.org/):

``` r

# Good
result <- od_get_issue(
  issue_number = 145,
  conn = connection
)

# Avoid
result<-od_get_issue(145,connection)
```

### Comments

- Keep comments concise
- Explain *why*, not *what*
- Update comments when code changes

``` r

# Good: explains intent
# Resolve UI number to internal API ID for REST call
issue_id <- od_resolve_issue_id(ui_number)

# Avoid: redundant
# Get issue ID
issue_id <- od_resolve_issue_id(ui_number)
```

### Error Messages

Be helpful and actionable:

``` r

# Good
if (is.null(host)) {
  stop("ONEDEV_HOST not set. Set via Sys.setenv() or od_connection()")
}

# Avoid
stop("host is required")
```

## Questions or Need Help?

- **GitHub Issues:** <https://github.com/alexseymer/onedevR/issues>
- **Discussions:** <https://github.com/alexseymer/onedevR/discussions>
- **Email:** <alexseymer@gmail.com>

## Useful Commands

``` r

# Install package in development mode
devtools::install(dependencies = TRUE)

# Run full checks
devtools::check()

# Run tests
devtools::test()

# Test coverage
devtools::test_coverage()

# Generate documentation
devtools::document()

# Build vignettes
devtools::build_vignettes()

# Check package
devtools::check()

# Check for spelling
devtools::spell_check()
```

## License

By contributing, you agree that your contributions will be licensed
under the same MIT License that covers the project.

------------------------------------------------------------------------

Thank you for contributing to onedevR! 🎉
