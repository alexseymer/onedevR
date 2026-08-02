# Cancel a running build

Calls `DELETE /job-runs/{buildId}`.

## Usage

``` r
od_cancel_job(build_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

## Value

`NULL` invisibly on success.
