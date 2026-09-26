# Code Refactoring Summary

This document summarizes the refactoring work completed to reduce code
duplication and improve maintainability across the onedevR codebase.

## Overview

**Total instances consolidated: 56**

Three primary helper functions were created to consolidate repeated code
patterns:

1.  `.od_coerce_string()` — String normalization (31 instances)
2.  `.od_resolve_entity_id()` — ID resolution (13 instances)
3.  `.od_require()` — Parameter validation (12 instances)

## Detailed Changes

### 1. String Normalization Helper (31 instances)

**Function:** `.od_coerce_string(x, trim = TRUE, default = "")`

**Problem:** The pattern `trimws(as.character(x %||% default)[1])`
appeared 31 times across the codebase.

**Solution:** Extracted into a reusable helper that: - Coerces value to
character - Handles NULL via `%||%` operator with default - Extracts
first element - Optionally trims whitespace

**Files modified:** - `R/connection.R` — 8 instances (host, token,
username, password, repo_url, project_id, default_issue_state) -
`R/repository.R` — 5 instances (branch, tag, commit_hash, revision,
path) - `R/packages.R` — 4 instances (query, pack_id × 3) - `R/users.R`
— 2 instances (user, query) - `R/pull_requests.R` — 2 instances (query,
status) - `R/request.R` — 2 instances (method × 2) - `R/projects.R` — 2
instances (project, query) - `R/issues.R` — 2 instances (query, state) -
`R/download.R` — 2 instances (resource_url, host) - `R/builds.R` — 2
instances (status, query) - `R/resolve.R` — 1 instance (project_path) -
`R/artifacts.R` — 1 instance (artifact_path)

**Before:**

``` r

branch <- trimws(as.character(branch %||% "")[1])
```

**After:**

``` r

branch <- .od_coerce_string(branch)
```

### 2. Entity ID Resolution Helper (13 instances)

**Function:**
`.od_resolve_entity_id(number, resolver_fn, use_internal_id = FALSE, conn = NULL)`

**Problem:** Multiple functions checked a `use_internal_id` flag,
conditionally calling `.od_strip_hash()` or a resolver function (13
times).

**Solution:** Extracted the conditional resolution logic into a single
helper that: - Returns the input as-is if already numeric (or
`use_internal_id` is TRUE) - Strips leading `#` from UI numbers - Calls
the provided resolver function for path/name → ID conversion

**Files modified:** - `R/issues.R` — 3 instances (od_get_issue,
od_get_issue_fields, od_get_issue_comments) - `R/builds.R` — 3 instances
(od_get_build, od_get_build_params, od_get_build_log) -
`R/pull_requests.R` — 3 instances (od_get_pull_request,
od_get_pull_request_comments, od_get_pull_request_reviews) -
`R/artifacts.R` — 2 instances (od_list_build_artifacts,
od_download_build_artifact) - `R/users.R` — 1 instance (od_get_user) -
`R/jobs.R` — 1 instance (od_cancel_job)

**Before:**

``` r

build_id <- if (isTRUE(use_internal_id)) {
  .od_strip_hash(build_number)
} else {
  od_resolve_build_id(build_number, conn = conn)
}
```

**After:**

``` r

build_id <- .od_resolve_entity_id(
  build_number,
  od_resolve_build_id,
  use_internal_id = use_internal_id,
  conn = conn
)
```

### 3. Parameter Validation Helper (12 instances)

**Function:** `.od_require(x, name)`

**Problem:** Required parameter validation appeared 12 times using the
pattern:

``` r

if (!nzchar(param)) {
  stop("`param` is required.", call. = FALSE)
}
```

**Solution:** Created a concise helper that: - Checks if a parameter is
non-empty - Stops with a clear, consistent error message if not

**Files modified:** - `R/jobs.R` — 3 instances (job_name, reason in
od_run_job, reason in od_rebuild_job) - `R/packages.R` — 3 instances
(pack_id in od_get_pack, od_get_pack_blobs, od_get_pack_labels) -
`R/repository.R` — 3 instances (branch, tag, commit_hash) -
`R/artifacts.R` — 2 instances (artifact_path, path) - `R/download.R` — 1
instance (path)

**Before:**

``` r

if (!nzchar(job_name)) {
  stop("`job_name` is required.", call. = FALSE)
}
```

**After:**

``` r

.od_require(job_name, "job_name")
```

## Benefits

✅ **DRY Principle**: Eliminated redundant code patterns  
✅ **Consistency**: Single source of truth for repeated logic  
✅ **Maintainability**: Easier to fix bugs or update behavior  
✅ **Readability**: Clearer intent with semantic function names  
✅ **Testability**: Helpers can be unit-tested independently

## Impact by Metric

| Metric                     | Value  |
|----------------------------|--------|
| Code duplication instances | 56 → 0 |
| Files modified             | 14     |
| Commits created            | 15     |
| New helper functions       | 3      |
| Lines of code consolidated | ~80+   |

## Testing

All refactoring changes maintain backward compatibility and pass
existing test suites. Run tests with:

``` r

devtools::test()
```

For live integration tests:

``` bash
ONEDEV_RUN_LIVE_TESTS=1 Rscript -e 'devtools::test()'
```

## Future Opportunities

Smaller patterns identified but deemed not worth immediate
consolidation:

- Field name variant handling (4 instances, camelCase/snake_case
  fallbacks)
- Count/offset query pagination (7 instances, function-specific
  parameters)
- Custom error messages (various, non-standard formats)

These patterns could be revisited if they expand significantly in the
future.
