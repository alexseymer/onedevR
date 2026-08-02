# Query OneDev builds

Query OneDev builds

## Usage

``` r
od_query_builds(
  query = NULL,
  status = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  Raw OneDev build query string (see
  [`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md)
  with `kind = "build"`, or `tod build get-query-description`). Example:
  `'"Number" is "group/project#100"'`.

- status:

  Optional status filter. OneDev uses keyword criteria - pass
  `"successful"`, `"failed"`, `"cancelled"`, `"timed out"`,
  `"finished"`, `"running"`, `"waiting"`, or `"pending"` (enum spellings
  like `"SUCCESSFUL"` are accepted and mapped). Combined with `query`
  via `and`.

- count:

  Maximum number of results (default `100`).

- offset:

  Result offset (default `0`).

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

A tibble of builds (default), or a list when `as_tibble = FALSE`.

## See also

Other builds:
[`od_cancel_job()`](https://alexseymer.github.io/onedevR/reference/od_cancel_job.md),
[`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md),
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
[`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md),
[`od_get_build_params()`](https://alexseymer.github.io/onedevR/reference/od_get_build_params.md),
[`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md),
[`od_rebuild_job()`](https://alexseymer.github.io/onedevR/reference/od_rebuild_job.md),
[`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md),
[`od_run_job()`](https://alexseymer.github.io/onedevR/reference/od_run_job.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_query_builds(status = "successful", count = 10L)
} # }
```
