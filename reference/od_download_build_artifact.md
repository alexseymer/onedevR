# Download a build artifact to a local file

Calls `GET /artifacts/{buildId}/contents/{artifactPath}` and writes the
raw bytes to `path`.

## Usage

``` r
od_download_build_artifact(
  build_number,
  artifact_path,
  path,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- artifact_path:

  Relative artifact path (required).

- path:

  Local destination file path.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

## Value

Normalized destination path, invisibly.
