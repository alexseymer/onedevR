# Get parameters for a build

Get parameters for a build

## Usage

``` r
od_get_build_params(build_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- build_number:

  character\|numeric UI number (`100` or `"#100"`).

- conn:

  list Connection list. Default: `NULL`.

- use_internal_id:

  logical If `TRUE`, treat `build_number` as the internal REST id.
  Default: `FALSE`.

## Value

list Parsed params payload.

## See also

Other builds:
[`od_cancel_job()`](https://alexseymer.github.io/onedevR/reference/od_cancel_job.md),
[`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md),
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
[`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md),
[`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md),
[`od_promote_build()`](https://alexseymer.github.io/onedevR/reference/od_promote_build.md),
[`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
[`od_rebuild_job()`](https://alexseymer.github.io/onedevR/reference/od_rebuild_job.md),
[`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md),
[`od_run_job()`](https://alexseymer.github.io/onedevR/reference/od_run_job.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_build_params(100)
} # }
```
