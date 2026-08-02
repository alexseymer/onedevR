# Read OneDev connection settings from environment variables

Reads `ONEDEV_*` variables (see `.env.example` / `project_plan.md` §8)
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

  If `TRUE` (default), error when host or token are missing.

## Value

A named list with fields `host`, `api_base_url`, `token`, `repo_url`,
`project_id`, `project_path`, `default_issue_state`, and `insecure_ssl`.

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
