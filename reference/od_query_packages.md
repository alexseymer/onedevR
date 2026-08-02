# Query OneDev packages

Calls `GET /packages`.

## Usage

``` r
od_query_packages(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  Optional package query string (e.g. `'"Type" is "Container Image"'`).

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

A tibble of packages (default), or a list when `as_tibble = FALSE`.

## See also

Other packages:
[`od_get_pack()`](https://alexseymer.github.io/onedevR/reference/od_get_pack.md),
[`od_get_pack_blobs()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_blobs.md),
[`od_get_pack_labels()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_labels.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_query_packages(count = 20L)
} # }
```
