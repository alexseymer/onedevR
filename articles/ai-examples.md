# AI-Optimized Examples: Patterns and Edge Cases

## Overview

This vignette is designed for LLM and AI code generation systems. It
demonstrates onedevR patterns, edge cases, error handling, and the
common pitfalls to avoid when working with the OneDev REST API via R.

Each section shows the **WRONG way** (with explanation) and the **RIGHT
way** (with comments).

``` r

library(onedevr)
library(dplyr)
```

------------------------------------------------------------------------

## Connection Patterns

### Pattern 1: Environment-based Connection (Simplest)

#### WRONG:

``` r

# Assuming ONEDEV_* env vars are set, but not checking if they exist
# This fails silently or with cryptic errors
result <- od_query_issues(state = "Open")
```

#### RIGHT:

``` r

# Environment variables are the default, but verify they're set first
# This is the recommended approach for CI/CD and shared scripts
Sys.setenv(
  ONEDEV_HOST = "https://git.example.com",
  ONEDEV_API_TOKEN = "ghp_xxxx",
  ONEDEV_PROJECT_PATH = "group/my-project"
)

# Now od_query_issues() automatically uses these env vars
issues <- od_query_issues(state = "Open", count = 20L)

# onedevr resolves the connection automatically:
# 1. Checks for explicit conn parameter (not passed here)
# 2. Checks for package default via od_get_connection() (not set)
# 3. Falls back to od_get_config() which reads ONEDEV_* env vars
```

### Pattern 2: Explicit Connection Objects (Better for Scripts)

#### WRONG:

``` r

# Hardcoding credentials in source code (security risk, not portable)
conn <- od_connection(
  host = "https://git.example.com",
  token = "my-secret-token",  # DON'T DO THIS
  project_path = "group/my-project"
)
```

#### RIGHT:

``` r

# Read credentials from environment or secrets management
conn <- od_connection(
  host = Sys.getenv("ONEDEV_HOST"),
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = Sys.getenv("ONEDEV_PROJECT_PATH")
)

# Use connection explicitly in function calls
issues <- od_query_issues(state = "Open", conn = conn)

# Or register as the package default for convenience
od_set_connection(conn)
issues <- od_query_issues(state = "Open")  # Now uses registered conn
```

### Pattern 3: Connection Reuse Across Multiple Calls

#### WRONG:

``` r

# Creating a new connection for each call (inefficient, repeated validation)
for (issue_num in c(145, 146, 147)) {
  conn <- od_connection(
    host = Sys.getenv("ONEDEV_HOST"),
    token = Sys.getenv("ONEDEV_API_TOKEN"),
    project_path = Sys.getenv("ONEDEV_PROJECT_PATH")
  )
  issue <- od_get_issue(issue_num, conn = conn)
  print(issue$title)
}
```

#### RIGHT:

``` r

# Create connection once, reuse across multiple calls
conn <- od_connection(
  host = Sys.getenv("ONEDEV_HOST"),
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = Sys.getenv("ONEDEV_PROJECT_PATH")
)

# Reuse the same connection object
for (issue_num in c(145, 146, 147)) {
  issue <- od_get_issue(issue_num, conn = conn)
  print(issue$title)
}

# Or use od_set_connection() to avoid passing conn repeatedly
od_set_connection(conn)
for (issue_num in c(145, 146, 147)) {
  issue <- od_get_issue(issue_num)  # conn is implicit
  print(issue$title)
}
```

### Pattern 4: Error Handling When Connection Fails

#### WRONG:

``` r

# No error handling - crashes on missing env var or network failure
Sys.unsetenv("ONEDEV_HOST")  # Simulate missing config
issues <- od_query_issues(state = "Open")
# ERROR: ONEDEV_HOST is missing or empty
# Script stops abruptly
```

#### RIGHT:

``` r

# Graceful error handling with informative messages
tryCatch(
  {
    # Try to query issues
    issues <- od_query_issues(state = "Open", count = 20L)
    cat("Successfully retrieved", nrow(issues), "issues\n")
  },
  error = function(e) {
    # Handle configuration or network errors
    if (grepl("ONEDEV_HOST", conditionMessage(e))) {
      cat("ERROR: OneDev host not configured. Set ONEDEV_HOST env var.\n")
    } else if (grepl("401", conditionMessage(e))) {
      cat("ERROR: Authentication failed. Check ONEDEV_API_TOKEN.\n")
    } else {
      cat("ERROR:", conditionMessage(e), "\n")
    }
    # Return NULL or safe default instead of crashing
    return(NULL)
  }
)
```

### Pattern 5: Using od_set_connection() for Defaults

#### WRONG:

``` r

# Forgetting that od_set_connection() sets a package-wide default
# This can cause unexpected behavior if another part of code expects different defaults
conn_prod <- od_connection(
  host = "https://prod.ondev.com",
  token = Sys.getenv("PROD_TOKEN"),
  project_path = "prod/myapp"
)
od_set_connection(conn_prod)

# Later, code that expects staging might use prod by accident
issues <- od_query_issues(state = "Open")  # Uses prod!
```

#### RIGHT:

``` r

# Use od_set_connection() for the PRIMARY default, but pass conn explicitly for exceptions
conn_prod <- od_connection(
  host = "https://prod.ondev.com",
  token = Sys.getenv("PROD_TOKEN"),
  project_path = "prod/myapp"
)
od_set_connection(conn_prod)

conn_staging <- od_connection(
  host = "https://staging.ondev.com",
  token = Sys.getenv("STAGING_TOKEN"),
  project_path = "staging/myapp"
)

# Production queries (using default)
prod_issues <- od_query_issues(state = "Open")

# Staging queries (explicit conn parameter overrides default)
staging_issues <- od_query_issues(state = "Open", conn = conn_staging)

# Clear default if needed (falls back to env vars)
od_set_connection(NULL)
```

------------------------------------------------------------------------

## Error Handling Patterns

### Pattern 1: Invalid UI Numbers (Negative, Non-existent, etc.)

#### WRONG:

``` r

# No validation - assumes the number exists
issue <- od_get_issue(-145)  # Negative number doesn't make sense
# OR
issue <- od_get_issue(999999)  # Likely doesn't exist
# No way to know if the call succeeded without checking the result
```

#### RIGHT:

``` r

# Validate UI numbers before use, or handle errors gracefully
issue_number <- 145

# Option 1: Simple try-catch
issue <- tryCatch(
  od_get_issue(issue_number),
  error = function(e) {
    cat("Issue #", issue_number, " not found:\n", conditionMessage(e), "\n")
    return(NULL)
  }
)

# Option 2: Validate locally before calling (faster)
if (!grepl("^#?[0-9]+$", issue_number)) {
  cat("Invalid issue number format:", issue_number, "\n")
} else {
  # Numeric UI numbers are positive integers
  if (as.integer(sub("^#", "", issue_number)) <= 0) {
    cat("Issue number must be positive\n")
  } else {
    issue <- od_get_issue(issue_number)
  }
}
```

### Pattern 2: Missing Required Parameters

#### WRONG:

``` r

# Forgetting required parameters like title when creating an issue
new_issue <- od_create_issue(
  # Missing: title = "..."
  description = "This is the description"
)
# ERROR: title is required
```

#### RIGHT:

``` r

# Check required parameters are provided
title <- "New feature request"
description <- "Add OAuth2 support"

# Validate required fields
if (!nzchar(title)) {
  stop("Issue title is required", call. = FALSE)
}

# Now create with all required fields
new_issue <- od_create_issue(
  title = title,
  description = description,
  fields = list(Priority = "Medium")
)

cat("Created issue #", new_issue$number, "\n")
```

### Pattern 3: Authentication Failures

#### WRONG:

``` r

# Invalid token - no clear error message about what went wrong
Sys.setenv(ONEDEV_API_TOKEN = "invalid_token_12345")
issues <- od_query_issues(state = "Open")
# ERROR: OneDev API request failed [HTTP 401]
# Unclear if it's the token, the host, or something else
```

#### RIGHT:

``` r

# Validate connection before using it
tryCatch(
  {
    # Explicitly validate the connection
    conn <- od_get_config(validate = TRUE)
    # If we get here, host and credentials are valid

    # Try a simple request to verify auth works
    test <- od_query_issues(state = "Open", count = 1L, conn = conn)
    cat("Authentication successful\n")
  },
  error = function(e) {
    msg <- conditionMessage(e)
    if (grepl("401|Unauthorized", msg)) {
      cat("ERROR: Authentication failed (401).\n")
      cat("Check ONEDEV_API_TOKEN and ONEDEV_AUTH settings.\n")
    } else if (grepl("ONEDEV_HOST|missing", msg)) {
      cat("ERROR: OneDev host not configured.\n")
      cat("Set ONEDEV_HOST environment variable.\n")
    } else {
      cat("ERROR:", msg, "\n")
    }
  }
)
```

### Pattern 4: Handling NULL Returns vs Errors

#### WRONG:

``` r

# Assuming od_query_issues() returns at least one row
# If no issues match, this crashes with a different error
issues <- od_query_issues(state = "Open", count = 100L)
highest_priority <- issues[1, ]$priority  # Error if nrow(issues) == 0
```

#### RIGHT:

``` r

# Check for empty results (NULL or empty tibble)
issues <- od_query_issues(state = "Open", count = 100L)

# Option 1: Check nrow explicitly
if (nrow(issues) == 0) {
  cat("No open issues found\n")
  highest_priority <- NA
} else {
  highest_priority <- issues[1, ]$priority
  cat("Highest priority issue:", highest_priority, "\n")
}

# Option 2: Use safe subsetting
if (nrow(issues) > 0) {
  # Safe: returns empty tibble if condition fails
  top_issues <- issues %>% filter(priority == "High")
  if (nrow(top_issues) > 0) {
    cat("Found", nrow(top_issues), "high priority issues\n")
  }
}

# Option 3: Handle as.list() safely for empty results
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
if (length(issues_list) == 0) {
  cat("No issues\n")
} else {
  first_title <- issues_list[[1]]$title
  cat("First issue:", first_title, "\n")
}
```

### Pattern 5: Try-Catch Patterns with onedevR

#### WRONG:

``` r

# Generic try-catch that doesn't distinguish between error types
result <- tryCatch(
  od_get_issue(issue_number),
  error = function(e) {
    # Can't tell if it's auth, not found, or network error
    cat("Something went wrong\n")
    return(NA)
  }
)
```

#### RIGHT:

``` r

# Structured error handling with specific error types
result <- tryCatch(
  od_get_issue(issue_number),
  error = function(e) {
    msg <- conditionMessage(e)

    # Check error message pattern and respond specifically
    if (grepl("not found", msg, ignore.case = TRUE)) {
      cat("Issue not found. Returning NULL.\n")
      return(NULL)
    } else if (grepl("401|Unauthorized", msg)) {
      cat("Authentication error. Fix your token and retry.\n")
      # In real code, might log this or alert the user
      return(NULL)
    } else if (grepl("404", msg)) {
      cat("Project not found. Check project path.\n")
      return(NULL)
    } else {
      # Generic error - log full message for debugging
      cat("Unexpected error:", msg, "\n")
      return(NULL)
    }
  }
)

# Now result is safely NULL on error, not an exception
if (!is.null(result)) {
  cat("Issue #", result$number, ":", result$title, "\n")
}
```

------------------------------------------------------------------------

## Parameter Flexibility Patterns

### Pattern 1: Functions Accepting UI Number OR Internal ID

#### WRONG:

``` r

# Mixing UI numbers and internal IDs without knowing which you have
# This is confusing because UI #145 != internal REST id
issue <- od_get_issue(145)  # Is this a UI number or internal id?
# Depends on context - ambiguous!
```

#### RIGHT:

``` r

# ALWAYS use UI numbers (what you see in web UI: #145)
# onedevR resolves them automatically to internal REST IDs
issue <- od_get_issue(145)  # Always a UI number

# If you happen to have an internal ID (rare, debugging only):
issue <- od_get_issue(
  "abc123def456",  # Some internal REST id
  use_internal_id = TRUE  # Explicit flag
)

# UI numbers can be specified with or without #
issue1 <- od_get_issue(145)      # Works
issue2 <- od_get_issue("#145")   # Also works (# is stripped)

# For builds and PRs, same pattern applies
build <- od_get_build(100)       # UI number
pull <- od_get_pull_request(5)   # UI number
```

### Pattern 2: Functions with Optional Parameters

#### WRONG:

``` r

# Passing all possible parameters even when they're not needed
# This is verbose and error-prone
issues <- od_query_issues(
  query = NULL,
  state = "Open",
  count = 100L,
  offset = 0L,
  as_tibble = TRUE,
  conn = od_get_config(validate = TRUE)
)
```

#### RIGHT:

``` r

# Use defaults and only pass what you need
# Much clearer intent

# Basic: just state
issues <- od_query_issues(state = "Open")

# With pagination
issues <- od_query_issues(state = "Open", count = 50L, offset = 0L)

# With custom query
issues <- od_query_issues(
  query = '"Number" >= 100 and "Priority" is "High"'
)

# With explicit connection (if needed)
conn <- od_connection(
  host = "https://example.com",
  token = "token",
  project_path = "group/project"
)
issues <- od_query_issues(state = "Open", conn = conn)
```

### Pattern 3: as_tibble Parameter Behavior

#### WRONG:

``` r

# Assuming as_tibble = TRUE always returns a tibble
result <- od_query_issues(state = "Open", as_tibble = TRUE)
# If something goes wrong in conversion, you get a tibble with one column: "value"

# Or assuming as_tibble = FALSE gives you a simple list
result <- od_query_issues(state = "Open", as_tibble = FALSE)
# Actually returns a list of issue objects (named lists)
title <- result[[1]]$title  # Must use $ not $ with tibble

# Mixing return types causes errors
if (is.list(result)) {  # Both TRUE and FALSE cases are lists!
  # This is ambiguous
}
```

#### RIGHT:

``` r

# Know the difference between as_tibble = TRUE and FALSE

# as_tibble = TRUE (default): Returns tibble, vectorized operations work
issues_df <- od_query_issues(state = "Open", as_tibble = TRUE)
# Can use dplyr verbs
high_priority <- issues_df %>%
  filter(priority == "High") %>%
  select(number, title)

# as_tibble = FALSE: Returns list of objects, easier to convert to other formats
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
# Can convert to JSON or send to external API
jsonlite::toJSON(issues_list, pretty = TRUE)

# Or extract specific field from all items
titles <- sapply(issues_list, function(x) x$title)

# Check explicitly what you're getting
result <- od_query_issues(state = "Open")
if (inherits(result, "data.frame")) {
  # It's a tibble/data.frame
  cat("Got", nrow(result), "issues\n")
} else if (is.list(result)) {
  # It's a list
  cat("Got", length(result), "issues\n")
}
```

### Pattern 4: Default vs Explicit Values

#### WRONG:

``` r

# Not sure what the defaults are, so over-specify everything
# This makes code fragile when defaults change
issues <- od_query_issues(
  query = NULL,  # Explicit NULL instead of omitting
  state = "Open",
  count = 100L,  # Don't know if this is the default
  offset = 0L,   # Don't know if this is the default
  as_tibble = NULL  # Explicit NULL confuses with getOption default
)
```

#### RIGHT:

``` r

# Rely on smart defaults, specify only what's intentional
# Refer to function docs for defaults:
# - query: NULL (omit for open filter)
# - state: NULL (falls back to conn$default_issue_state or all)
# - count: 100L (pagination size)
# - offset: 0L (start at beginning)
# - as_tibble: NULL (use getOption("onedevr.as_tibble", TRUE))

# Simple case: just state
issues <- od_query_issues(state = "Open")

# Pagination: only specify count if different from default
issues <- od_query_issues(state = "Open", count = 50L)

# Custom query: don't specify count unless you need different pagination
issues <- od_query_issues(query = '"Number" >= 100')

# For as_tibble, omit it unless you specifically want lists
issues_df <- od_query_issues(state = "Open")  # Default: TRUE, returns tibble
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)  # Explicit lists

# Global default for as_tibble
options(onedevr.as_tibble = FALSE)  # Change default to lists
issues <- od_query_issues(state = "Open")  # Now returns list
```

### Pattern 5: When to Use project = NULL vs Explicit

#### WRONG:

``` r

# Assuming project is required for all functions
# Actually, some functions work without a project (user/team level queries)

# This fails because project is required
iterations <- od_list_iterations()  # No project specified!
# ERROR: missing project path

# Or passing empty string when NULL is clearer
issue <- od_get_issue(
  145,
  project = "",  # Wrong: should be NULL
  conn = conn
)
```

#### RIGHT:

``` r

# Understand which functions require project context

# Functions that REQUIRE project (from od_set_connection or env var):
issues <- od_query_issues(state = "Open")  # Uses project from connection

# Functions that REQUIRE project EXPLICITLY:
artifacts <- od_list_build_artifacts(
  build_number = 123,
  project = "group/my-project"  # Must provide project
)

# User/team level queries (no project needed):
users <- od_query_users()  # Works without project
groups <- od_list_groups()  # Works without project

# To use different project than default:
conn <- od_connection(
  host = "https://example.com",
  token = "token",
  project_path = "default/project"
)
issues <- od_query_issues(state = "Open", conn = conn)

# To override project for specific call:
# Some functions accept project parameter:
other_project_issues <- od_query_issues(
  state = "Open",
  project = "other/project"  # Override default
)
```

------------------------------------------------------------------------

## Pagination & Large Result Sets

### Pattern 1: Using count and offset Parameters

#### WRONG:

``` r

# Fetching all issues in one call - works for small datasets, fails for large ones
all_issues <- od_query_issues(state = "Open", count = 10000L)
# If there are more than 10000, you get incomplete data and don't know it

# Manual pagination with loop - error-prone
issues_list <- list()
offset <- 0
while (TRUE) {
  batch <- od_query_issues(state = "Open", count = 100L, offset = offset)
  if (nrow(batch) == 0) break  # Relies on knowing structure
  issues_list <- c(issues_list, list(batch))
  offset <- offset + 100L
}
all_issues <- do.call(rbind, issues_list)
```

#### RIGHT:

``` r

# Understand pagination limits and use them correctly
# Most OneDev instances have a max page size (e.g., 100-500)

# Fetch with explicit limits (knowing max returns per request)
first_page <- od_query_issues(state = "Open", count = 50L, offset = 0L)
cat("Retrieved", nrow(first_page), "issues\n")

# For multiple pages, combine results
second_page <- od_query_issues(state = "Open", count = 50L, offset = 50L)
both_pages <- bind_rows(first_page, second_page)

# For unknown total count, check if response is smaller than requested
first_100 <- od_query_issues(state = "Open", count = 100L, offset = 0L)
if (nrow(first_100) < 100) {
  # Got fewer than requested, means we have all results
  all_issues <- first_100
} else {
  # There might be more, continue paginating
  all_issues <- first_100
  offset <- 100L
  while (TRUE) {
    batch <- od_query_issues(state = "Open", count = 100L, offset = offset)
    if (nrow(batch) == 0) break
    all_issues <- bind_rows(all_issues, batch)
    offset <- offset + 100L
  }
}
```

### Pattern 2: od_paginate() Usage

#### WRONG:

``` r

# Not knowing od_paginate() exists and manually implementing pagination
all_builds <- list()
for (offset in seq(0, 5000, by = 50)) {
  batch <- od_query_builds(
    status = "successful",
    count = 50L,
    offset = offset
  )
  if (nrow(batch) == 0) break
  all_builds <- c(all_builds, list(batch))
}
all_builds_df <- do.call(rbind, all_builds)
```

#### RIGHT:

``` r

# Use od_paginate() helper - it handles pagination transparently
# Signature: od_paginate(func, page_size, max_pages, ...)

# Fetch all issues with pagination (auto-combines pages)
all_issues <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 50L,
  max_pages = Inf  # Fetch all available pages
)
cat("Retrieved", nrow(all_issues), "total issues\n")

# Limit to first 5 pages
first_250 <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 50L,
  max_pages = 5L
)

# With custom query
high_priority_all <- od_paginate(
  od_query_issues,
  query = '"Priority" is "High"',
  page_size = 100L,
  max_pages = Inf
)

# od_paginate() works with any query function
all_builds <- od_paginate(
  od_query_builds,
  status = "successful",
  page_size = 50L,
  max_pages = Inf
)
```

### Pattern 3: Iterating Through Large Result Sets

#### WRONG:

``` r

# Loading all results into memory at once
all_issues <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 100L,
  max_pages = Inf
)
# If there are 100k issues, this uses lots of memory
# Then processing them all at once
for (i in seq_len(nrow(all_issues))) {
  # Process each row
}
```

#### RIGHT:

``` r

# Option 1: Process pages incrementally (if using manual pagination)
process_issues <- function(page) {
  # Do something with each page of issues
  cat("Processing", nrow(page), "issues\n")
  # Example: Update each issue
  for (i in seq_len(nrow(page))) {
    issue_num <- page[i, ]$number
    # Do work with issue_num
  }
  invisible(NULL)
}

# Manually iterate with pagination
offset <- 0
repeat {
  batch <- od_query_issues(state = "Open", count = 100L, offset = offset)
  if (nrow(batch) == 0) break

  # Process batch without keeping all in memory
  process_issues(batch)

  offset <- offset + 100L
}

# Option 2: If you need all results, use od_paginate() then iterate
# It's more efficient than manual pagination
all_issues <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 100L,
  max_pages = Inf
)

# Process with dplyr to avoid loading entire result set at once
all_issues %>%
  filter(state == "Open") %>%
  mutate(age_days = as.numeric(Sys.Date() - created_date)) %>%
  arrange(desc(age_days)) %>%
  slice(1:10) %>%  # Take top 10
  pull(number)     # Extract just the numbers
```

### Pattern 4: Limiting Results Efficiently

#### WRONG:

``` r

# Fetching way more data than needed, then limiting
all_issues <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 100L,
  max_pages = Inf
)
# Now filter to high priority
high_priority <- all_issues %>% filter(priority == "High")
# If there are 10k total but only 100 high priority, you wasted time/bandwidth
```

#### RIGHT:

``` r

# Use query filters to get only what you need
# OneDev query language supports this
high_priority <- od_paginate(
  od_query_issues,
  query = '"Priority" is "High"',
  page_size = 100L,
  max_pages = Inf
)
# Now result set is already filtered

# For top N results with pagination:
top_10_recent <- od_query_issues(
  state = "Open",
  count = 10L,
  offset = 0L
)
# Default sorting might be by created date (check docs)

# For specific limit with multiple pages:
top_100 <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 50L,
  max_pages = 2L  # Only fetch 2 pages = 100 items max
)

# Combining query filter + pagination
recent_high_priority <- od_paginate(
  od_query_issues,
  query = '"Priority" is "High" and "Created" >= -7d',  # Last 7 days
  page_size = 100L,
  max_pages = Inf
)
```

------------------------------------------------------------------------

## Data Transformation Patterns

### Pattern 1: Converting Tibbles to Lists

#### WRONG:

``` r

# Assuming as_tibble = FALSE gives you a simple list
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
# Actually returns: list of issue objects (each is a named list)

# Trying to access like a simple vector
titles <- issues_list$title
# ERROR: NULL (because $ doesn't work that way)

# Converting tibble to list without understanding the structure
issues_df <- od_query_issues(state = "Open", as_tibble = TRUE)
issues_list <- as.list(issues_df)
# This doesn't give you what you want - it just converts columns to list
```

#### RIGHT:

``` r

# Understanding the two formats:

# Format 1: as_tibble = TRUE (default) - returns tibble/data.frame
issues_df <- od_query_issues(state = "Open", as_tibble = TRUE)
# Can work with columns directly
titles <- issues_df$title
# Can use dplyr
high_priority <- issues_df %>% filter(priority == "High")

# Format 2: as_tibble = FALSE - returns list of objects
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
# Each element is a complete issue object (named list)
first_issue <- issues_list[[1]]
first_title <- first_issue$title
# Extract titles from all issues
titles <- sapply(issues_list, function(x) x$title)

# Converting between formats:
# From tibble to list of objects
issues_df <- od_query_issues(state = "Open", as_tibble = TRUE)
issues_list <- lapply(seq_len(nrow(issues_df)), function(i) {
  as.list(issues_df[i, ])
})

# From list back to tibble
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
issues_df <- tibble::as_tibble(
  do.call(rbind, lapply(issues_list, as.data.frame))
)
```

### Pattern 2: Extracting Fields from Results

#### WRONG:

``` r

# Trying to extract nested fields without understanding structure
issues <- od_query_issues(state = "Open")
# Assume all fields are simple columns
assignee_name <- issues$assignee$name
# ERROR: $ doesn't work on list-columns

# Or when as_tibble = FALSE
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
assignee <- issues_list$assignee  # Wrong: no column, it's a list of objects
assignee <- issues_list[[1]]$assignee  # Right: must access object first
```

#### RIGHT:

``` r

# With tibble format (as_tibble = TRUE):
issues <- od_query_issues(state = "Open", as_tibble = TRUE)

# Simple fields work directly
titles <- issues$title
numbers <- issues$number

# Nested objects become list-columns (use tidyr or manual extraction)
if (is_list_col(issues$assignee)) {
  # Extract nested field
  assignees <- sapply(issues$assignee, function(x) {
    if (is.null(x)) NA else x$name
  })
} else {
  assignees <- issues$assignee  # Simple field
}

# With list format (as_tibble = FALSE):
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)

# Extract field from all objects
titles <- sapply(issues_list, function(x) x$title)
numbers <- sapply(issues_list, function(x) x$number)

# Extract nested field
assignee_names <- sapply(issues_list, function(x) {
  if (is.null(x$assignee)) NA else x$assignee$name
})

# Safe extraction (handle NULLs)
priorities <- sapply(issues_list, function(x) {
  x$priority %||% "Unset"
}, USE.NAMES = FALSE)
```

### Pattern 3: Combining Results from Multiple Calls

#### WRONG:

``` r

# Fetching related data separately then trying to combine
issues <- od_query_issues(state = "Open")
# Now I need to get details for each issue
for (issue_num in issues$number) {
  details <- od_get_issue(issue_num)
  # How do I combine this back with issues df?
  # Requires manual matching by ID
}

# Or using rbind without checking structure compatibility
all_results <- NULL
for (query in c("Open", "In Progress", "Closed")) {
  batch <- od_query_issues(state = query)
  all_results <- rbind(all_results, batch)  # Risky if columns differ
}
```

#### RIGHT:

``` r

# Use dplyr::bind_rows() for safe combining (handles missing columns)
all_issues <- dplyr::bind_rows(
  od_query_issues(state = "Open"),
  od_query_issues(state = "In Progress"),
  od_query_issues(state = "Closed")
)

# Or using od_paginate() for same query
all_issues <- od_paginate(
  od_query_issues,
  state = "Open",
  page_size = 100L,
  max_pages = Inf
)

# For joining related data from multiple endpoints:
issues <- od_query_issues(state = "Open")

# Get additional details for each issue (not always needed)
if (nrow(issues) > 0) {
  # Only fetch details if you really need them
  details <- issues %>%
    pull(number) %>%
    lapply(od_get_issue) %>%
    bind_rows()

  # Join back to original (assuming number is unique key)
  combined <- left_join(issues, details, by = c("number" = "number"))
}

# Better: see if the initial query includes what you need
# before fetching additional details
issues <- od_query_issues(state = "Open")
# Check what fields are available
str(issues)
# If you have what you need, don't fetch more
```

### Pattern 4: Processing Nested Structures

#### WRONG:

``` r

# Assuming nested objects are always present and structured the same way
issues <- od_query_issues(state = "Open")

# Accessing nested fields without checking nullability
creator_name <- issues$creator$name  # Might be NULL or NA
assignee <- issues$assignee$login   # Nested object might be NULL

# Getting an error because structure isn't what you expected
comments_count <- issues$comments_count  # Might not exist at all
```

#### RIGHT:

``` r

# Handle nested/optional fields safely

# First, understand the structure
issues <- od_query_issues(state = "Open", count = 1L)
str(issues)  # See what's actually there

# Safe extraction of nested fields
issues <- od_query_issues(state = "Open")

# Option 1: sapply with safe access
creators <- sapply(issues$creator, function(x) {
  if (is.null(x)) "Unknown" else (x$name %||% "Unknown")
}, USE.NAMES = FALSE)

# Option 2: Use tidyr::unnest (if fields are list-columns)
if (inherits(issues, "data.frame")) {
  issues_wide <- issues %>%
    # Keep simple columns
    select(-starts_with("creator"), -starts_with("assignee")) %>%
    # Add flattened nested fields
    mutate(
      creator_name = sapply(.$creator, function(x) x$name %||% NA),
      assignee_name = sapply(.$assignee, function(x) x$name %||% NA)
    )
}

# Option 3: Use list format for easier access
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
for (issue in issues_list) {
  cat("Issue #", issue$number, "\n")
  if (!is.null(issue$creator)) {
    cat("  Creator:", issue$creator$name, "\n")
  } else {
    cat("  Creator: Unknown\n")
  }
}
```

------------------------------------------------------------------------

## Common Mistakes & How to Avoid

### Mistake 1: Forgetting to Pass conn Parameter

#### WRONG:

``` r

# Setting up connection but not using it
conn <- od_connection(
  host = Sys.getenv("ONEDEV_HOST"),
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "mygroup/myproject"
)

# Then querying without passing conn
issues <- od_query_issues(state = "Open")
# Falls back to environment variables, not the connection object
# If env vars are different, you get unexpected results

# This is subtle - no error, just wrong connection used
```

#### RIGHT:

``` r

# Option 1: Pass conn to every call
conn <- od_connection(
  host = Sys.getenv("ONEDEV_HOST"),
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "mygroup/myproject"
)
issues <- od_query_issues(state = "Open", conn = conn)

# Option 2: Register as default (then no need to pass every time)
od_set_connection(conn)
issues <- od_query_issues(state = "Open")  # Uses registered conn

# Option 3: If using env vars, just use od_get_config()
Sys.setenv(
  ONEDEV_HOST = "...",
  ONEDEV_API_TOKEN = "...",
  ONEDEV_PROJECT_PATH = "..."
)
issues <- od_query_issues(state = "Open")  # Uses env vars automatically

# Check which connection is being used
current <- .od_conn()  # Internal function to see active connection
cat("Using host:", current$host, "\n")
```

### Mistake 2: Using Internal ID vs UI Number Incorrectly

#### WRONG:

``` r

# Not understanding the difference
# You see "#145" in the web UI
# But od_resolve_issue_id(145) might return "6a7b9c2d"

# Then assuming they're interchangeable
issue_id <- "6a7b9c2d"  # Internal REST id
issue <- od_request("GET", paste0("/issues/", issue_id))

# But trying to use it in queries as UI number
issues <- od_query_issues(query = paste0('"Number" is "', issue_id, '"'))
# Doesn't work - queries expect UI numbers

# Mixing them up:
issue_info <- od_get_issue("6a7b9c2d")  # Treated as UI number, doesn't work
```

#### RIGHT:

``` r

# Clear mental model:
# - UI numbers (#145) are what you see in the OneDev web UI
# - Internal REST IDs (e.g., "6a7b9c2d") are for direct API calls
# - onedevR functions accept UI numbers and resolve them automatically

# Correct usage:
# Use UI numbers with high-level functions
issue <- od_get_issue(145)  # Always UI number

# If you need the internal ID for direct API calls:
internal_id <- od_resolve_issue_id(145)
# Now use internal_id for od_request() if needed
issue_raw <- od_request("GET", paste0("/issues/", internal_id))

# Never mix up the formats in queries
# This WRONG:
wrong <- od_query_issues(query = paste0('"Number" is "', internal_id, '"'))
# This RIGHT:
right <- od_query_issues(query = paste0('"Number" is "145"'))
```

### Mistake 3: Not Handling NULL Returns

#### WRONG:

``` r

# Assuming a query always returns something
issues <- od_query_issues(state = "NonExistent")
# Returns empty tibble, but code expects data
first_issue <- issues[1, ]  # Gets NA row
title <- first_issue$title  # NA, but code might not handle it

# Or with as_tibble = FALSE
issues_list <- od_query_issues(state = "NonExistent", as_tibble = FALSE)
first <- issues_list[[1]]  # NULL or error - list is empty
title <- first$title       # Crash!
```

#### RIGHT:

``` r

# Always check for empty results
issues <- od_query_issues(state = "Open")

# Safe check before accessing rows
if (nrow(issues) > 0) {
  first_issue <- issues[1, ]
  title <- first_issue$title
  cat("First issue:", title, "\n")
} else {
  cat("No open issues found\n")
}

# With list format
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
if (length(issues_list) > 0) {
  first <- issues_list[[1]]
  title <- first$title
  cat("First issue:", title, "\n")
} else {
  cat("No open issues found\n")
}

# Pipeline-friendly approach with dplyr
issues <- od_query_issues(state = "Open")
top_issues <- issues %>%
  filter(priority == "High") %>%
  slice(1:5)  # slice returns empty tibble if not enough rows

if (nrow(top_issues) > 0) {
  cat("Top high-priority issues:\n")
  print(top_issues$title)
}
```

### Mistake 4: Misunderstanding as_tibble Behavior

#### WRONG:

``` r

# Assuming as_tibble only affects the return type, not the structure
result1 <- od_query_issues(state = "Open", as_tibble = TRUE)
result2 <- od_query_issues(state = "Open", as_tibble = FALSE)
# Assuming I can work with them the same way
# Both are lists from R's perspective, but different structures

titles1 <- result1$title    # Works: tibble column
titles2 <- result2$title    # NULL: not a column in list of objects

# Or assuming nested fields are handled the same way
result1$creator$name        # NULL: can't chain like this on tibble
result2[[1]]$creator$name   # Works: object access
```

#### RIGHT:

``` r

# Different return types require different access patterns

# as_tibble = TRUE: Returns tibble (rectangular data)
issues_df <- od_query_issues(state = "Open", as_tibble = TRUE)
str(issues_df)  # See structure

# Access columns
titles <- issues_df$title
states <- issues_df$state

# Use dplyr
top <- issues_df %>%
  filter(priority == "High") %>%
  arrange(desc(created_date)) %>%
  slice(1:5)

# as_tibble = FALSE: Returns list of objects
issues_list <- od_query_issues(state = "Open", as_tibble = FALSE)
# Each element is a complete object
titles <- sapply(issues_list, function(x) x$title)
states <- sapply(issues_list, function(x) x$state)

# Or convert to JSON for external use
json <- jsonlite::toJSON(issues_list, pretty = TRUE)

# Choose based on your need:
# - Tibble: data analysis, dplyr operations, export to CSV/Excel
# - List: API integration, JSON serialization, field-level flexibility
```

### Mistake 5: Incorrect Query Syntax

#### WRONG:

``` r

# Using SQL-like syntax instead of OneDev query syntax
issues <- od_query_issues(
  query = 'WHERE state = "Open" AND priority = "High"'  # SQL, not OneDev
)
# ERROR: Query syntax error

# Or using incorrect field names
issues <- od_query_issues(
  query = '"issue_state" is "Open"'  # Wrong field name
)
# ERROR: Unknown field

# Or incorrect operator
issues <- od_query_issues(
  query = '"Priority" == "High"'  # SQL operator, not OneDev
)
# ERROR: Syntax error
```

#### RIGHT:

``` r

# Use OneDev query syntax (closer to English)
# See docs with: od_get_query_description("issue")

# Correct syntax patterns:
# "Field" is "Value"
# "Field" contains "partial"
# "Field" >= value
# condition1 and condition2
# condition1 or condition2

issues <- od_query_issues(
  query = '"State" is "Open" and "Priority" is "High"'
)

# Multiple conditions
issues <- od_query_issues(
  query = '"Number" >= 100 and "Number" <= 200 and "State" is "Open"'
)

# Assignee queries
my_issues <- od_query_issues(
  query = '"Assignee" is currentUser()'
)

unassigned <- od_query_issues(
  query = '"Assignee" is empty'
)

# If unsure of syntax, use state parameter instead of query
open_high <- od_query_issues(state = "Open")  # Then filter in R
# Or check docs
cat(od_get_query_description("issue"))
```

------------------------------------------------------------------------

## For LLM/AI Users

### What onedevR Does Well

1.  **Automatic ID Resolution**: You specify UI numbers (#145), onedevR
    handles internal REST ID conversion. No need to manually resolve.

2.  **Connection Flexibility**: Works with environment variables or
    explicit connection objects. Easy to switch between multiple OneDev
    instances.

3.  **Consistent Patterns**: All high-level functions follow the same
    interface (`od_query_*`, `od_get_*`, `od_create_*`). Predictable
    naming and parameters.

4.  **Tibble-First Results**: Default tibble format integrates
    seamlessly with dplyr for data wrangling. Easy to filter, group,
    summarize.

5.  **Pagination Helper**:
    [`od_paginate()`](https://alexseymer.github.io/onedevR/reference/od_paginate.md)
    abstracts away pagination complexity. Fetch all results with one
    call.

6.  **Error Handling**: HTTP errors include OneDev API error messages,
    not just HTTP status codes. Helps debug issues.

### What to Watch Out For

1.  **Connection Scope**:
    [`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md)
    sets a package-wide default. Forgetting this can cause operations to
    use wrong host/credentials.

2.  **UI Numbers vs Internal IDs**: Always use UI numbers (#145).
    Internal IDs are for debugging or direct API calls via
    [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md).

3.  **Empty Results**: Query functions can return empty tibbles (0
    rows). Always check `nrow() > 0` or `length() > 0` before accessing
    first element.

4.  **as_tibble Behavior**: Returns tibble vs list of objects have
    completely different access patterns. Choose based on how you’ll use
    the data.

5.  **Nested Fields**: Complex objects (assignee, creator) might be NULL
    or have different structures. Safe extraction requires defensive
    coding.

6.  **Query Syntax**: OneDev query language is not SQL. Always verify
    syntax with
    [`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md)
    when unsure.

### When to Use od_request() Escape Hatch

Use
[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
when onedevR doesn’t provide a high-level helper:

``` r

# One-off API call
result <- od_request(
  method = "GET",
  endpoint = "/projects/myproject/custom-endpoint"
)

# Custom POST request
response <- od_request(
  method = "POST",
  endpoint = "/issues",
  body = list(title = "New", description = "Details")
)

# With explicit connection
result <- od_request(
  method = "GET",
  endpoint = "/builds",
  conn = my_conn
)
```

But prefer high-level helpers when available - they handle common edge
cases.

### Common Workflows

#### Bulk Issue Updates

``` r

library(dplyr)

# Get all high-priority open issues
high_priority <- od_query_issues(
  query = '"Priority" is "High" and "State" is "Open"'
)

# Update each
for (i in seq_len(nrow(high_priority))) {
  issue_num <- high_priority[i, ]$number
  od_issue_set_fields(issue_num, Assignee = "alice")
}
```

#### Generate Report

``` r

library(dplyr)

all_issues <- od_paginate(
  od_query_issues,
  count = 100L
)

report <- all_issues %>%
  group_by(state, priority) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(desc(count))

print(report)
```

#### Monitor Build Status

``` r

# Fetch recent builds
recent <- od_query_builds(count = 20L)

# Find failed ones
failed <- recent %>%
  filter(grepl("failed|error", status, ignore.case = TRUE))

if (nrow(failed) > 0) {
  for (i in seq_len(nrow(failed))) {
    build_num <- failed[i, ]$number
    log <- od_get_build_log(build_num)
    cat("Build #", build_num, " failed:\n")
    cat(log, "\n")
  }
}
```

#### Cross-Repo Synchronization

``` r

# Create connection to two instances
prod <- od_connection(
  host = "https://prod.ondev.com",
  token = Sys.getenv("PROD_TOKEN"),
  project_path = "main/app"
)

staging <- od_connection(
  host = "https://staging.ondev.com",
  token = Sys.getenv("STAGING_TOKEN"),
  project_path = "testing/app"
)

# Sync issues from prod to staging
prod_issues <- od_query_issues(state = "Open", conn = prod)

for (i in seq_len(nrow(prod_issues))) {
  issue <- prod_issues[i, ]
  od_create_issue(
    title = issue$title,
    description = issue$description,
    conn = staging
  )
}
```

------------------------------------------------------------------------

### Final Notes

This vignette covers patterns optimized for LLM code generation. When
generating onedevR code:

1.  **Always handle errors** - Use tryCatch for API calls
2.  **Check for empty results** - Verify nrow() \> 0 or length() \> 0
3.  **Use UI numbers** - Never assume internal IDs
4.  **Prefer high-level helpers** - Use `od_query_*` instead of raw
    [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
5.  **Understand as_tibble** - Know which format you’re getting and use
    accordingly
6.  **Validate connections** - Check that host and credentials are
    configured
7.  **Use od_paginate()** - Don’t implement manual pagination
8.  **Extract nested fields safely** - Handle NULL and missing fields

For more patterns and workflows, see: -
[`vignette("getting-started", package = "onedevr")`](https://alexseymer.github.io/onedevR/articles/getting-started.md) -
`vignette("issues", package = "onedevr")` -
`vignette("builds", package = "onedevr")` -
`vignette("pull-requests", package = "onedevr")`
