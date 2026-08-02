# List build artifact metadata

Calls `GET /artifacts/{buildId}/infos[/{path}]`. Omit `artifact_path`
for the artifact root; pass a relative path to list a subdirectory.

## Usage

``` r
od_list_build_artifacts(
  build_number,
  artifact_path = NULL,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- artifact_path:

  Optional relative artifact path (no leading `/`).

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

## Value

A tibble of artifact info (default), or a list when `as_tibble = FALSE`.
