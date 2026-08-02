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
