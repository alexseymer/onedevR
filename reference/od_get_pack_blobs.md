# Get blobs for a package

Get blobs for a package

## Usage

``` r
od_get_pack_blobs(pack_id, as_tibble = NULL, conn = NULL)
```

## Arguments

- pack_id:

  Package id.

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

A tibble of blobs (default), or a list when `as_tibble = FALSE`.

## See also

Other packages:
[`od_get_pack()`](https://alexseymer.github.io/onedevR/reference/od_get_pack.md),
[`od_get_pack_labels()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_labels.md),
[`od_query_packages()`](https://alexseymer.github.io/onedevR/reference/od_query_packages.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_pack_blobs(1)
} # }
```
