# Rebuild (resubmit) a finished or existing build

Posts to `POST /job-runs/rebuild`.

## Usage

``` r
od_rebuild_job(
  build_number,
  reason = "Rebuild via onedevr",
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- reason:

  Reason string (required by OneDev).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

## Value

`NULL` invisibly on success (empty API body).

## See also

Other builds:
[`od_cancel_job()`](https://alexseymer.github.io/onedevR/reference/od_cancel_job.md),
[`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md),
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
[`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md),
[`od_get_build_params()`](https://alexseymer.github.io/onedevR/reference/od_get_build_params.md),
[`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md),
[`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
[`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md),
[`od_run_job()`](https://alexseymer.github.io/onedevR/reference/od_run_job.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_rebuild_job(100)
} # }
```
