# Build an explicit OneDev connection

Prefer this over environment variables for scripts and multi-host
workflows. Pass the result as `conn =` to high-level helpers, or
register it as the package default with
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md).

## Usage

``` r
od_connection(
  host,
  token = NULL,
  username = NULL,
  password = NULL,
  auth = NULL,
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

  character OneDev base URL (e.g. `"https://git.example.test"`).

- token:

  character API access token (Bearer), or Basic Auth password when
  `auth = "basic"` and `password` is unset. Default: `NULL`.

- username:

  character Optional username for Basic Auth. Default: `NULL`.

- password:

  character Optional Basic Auth password (defaults to `token` when
  unset). Default: `NULL`.

- auth:

  character `"bearer"` or `"basic"`. Default: `"basic"` when `username`
  is set, otherwise `"bearer"`. Default: `NULL`.

- project_path:

  character Project path (e.g. `"group/my-project"`). Default: `NULL`.

- project_id:

  character\|numeric Optional numeric project id (skips path resolution
  when set). Default: `NULL`.

- repo_url:

  character Optional git remote URL; used to derive `project_path` when
  that is unset. Default: `NULL`.

- default_issue_state:

  character Optional default for
  [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md)
  when no query/state is given. Default: `NULL`.

- insecure_ssl:

  logical If `TRUE`, skip TLS certificate verification. Default:
  `FALSE`.

- validate:

  logical If `TRUE` (default), error when host/credentials are missing.
  Default: `TRUE`.

## Value

list A named list with connection fields, classed as `od_connection`.

## Details

Authentication is **Bearer** by default (`token`). For **Basic Auth**,
set `username` (and `password`, or reuse `token` as the password) -
`auth` is inferred as `"basic"` when `username` is non-empty, or set
`auth = "basic"` explicitly.

## See also

Other connection:
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md),
[`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md),
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md)

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "group/my-project"
)
od_get_issue(145, conn = conn)

basic <- od_connection(
  host = "https://git.example.test",
  username = "alice",
  password = "secret",
  project_path = "group/my-project"
)
} # }
```
