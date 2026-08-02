# Read OneDev connection settings from environment variables

Reads `ONEDEV_*` variables (see `.Renviron.example` / `.env.example`)
and returns a connection list used by high-level `od_*` helpers. Prefer
an explicit
[`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
(optionally registered with
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md))
for scripts; env remains the fallback when no connection is passed or
registered.

## Usage

``` r
od_get_config(validate = TRUE)
```

## Arguments

- validate:

  If `TRUE` (default), error when host or credentials are missing.

## Value

A named list with fields `host`, `api_base_url`, `token`, `username`,
`password`, `auth`, `repo_url`, `project_id`, `project_path`,
`default_issue_state`, and `insecure_ssl`.

## Details

Auth: Bearer via `ONEDEV_API_TOKEN` (or aliases). Basic Auth when
`ONEDEV_USERNAME` is set (password from `ONEDEV_PASSWORD`, or the token
as password). Override with `ONEDEV_AUTH=bearer|basic`.

## See also

Other connection:
[`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md),
[`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md),
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md)

## Examples

``` r
if (FALSE) { # \dontrun{
Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = "token",
  ONEDEV_PROJECT_PATH = "group/my-project"
)
od_get_config()
} # }
```
