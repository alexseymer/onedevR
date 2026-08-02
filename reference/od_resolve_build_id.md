# Resolve a UI build number to the internal REST id

Same Number-query variants as
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md).

## Usage

``` r
od_resolve_build_id(build_number, conn = NULL)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character internal build id.

## See also

Other builds:
[`od_cancel_job()`](https://alexseymer.github.io/onedevR/reference/od_cancel_job.md),
[`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md),
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
[`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md),
[`od_get_build_params()`](https://alexseymer.github.io/onedevR/reference/od_get_build_params.md),
[`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md),
[`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
[`od_rebuild_job()`](https://alexseymer.github.io/onedevR/reference/od_rebuild_job.md),
[`od_run_job()`](https://alexseymer.github.io/onedevR/reference/od_run_job.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_resolve_build_id(100)
} # }
```
