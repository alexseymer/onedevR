# Build an explicit OneDev connection

Prefer this over environment variables for scripts and multi-host
workflows. Pass the result as `conn =` to high-level helpers, or
register it as the package default with
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md).

## Usage

``` r
od_connection(
  host,
  token,
  project_path = NULL,
  project_id = NULL,
  repo_url = NULL,
  default_issue_state = NULL,
  insecure_ssl = FALSE,
  validate = TRUE
)
```

## Arguments

- host:

  OneDev base URL (e.g. `"https://git.example.test"`).

- token:

  API access token (Bearer).

- project_path:

  Project path (e.g. `"group/my-project"`).

- project_id:

  Optional numeric project id (skips path resolution when set).

- repo_url:

  Optional git remote URL; used to derive `project_path` when that is
  unset.

- default_issue_state:

  Optional default for
  [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md)
  when no query/state is given.

- insecure_ssl:

  If `TRUE`, skip TLS certificate verification.

- validate:

  If `TRUE` (default), error when `host` or `token` are empty.

## Value

A named list with the same fields as
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md),
classed as `od_connection`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "group/my-project"
)
od_get_issue(145, conn = conn)
} # }
```
