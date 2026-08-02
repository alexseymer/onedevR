# Get a package by id

Get a package by id

## Usage

``` r
od_get_pack(pack_id, conn = NULL)
```

## Arguments

- pack_id:

  Package id.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed package object (list).

## See also

Other packages:
[`od_get_pack_blobs()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_blobs.md),
[`od_get_pack_labels()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_labels.md),
[`od_query_packages()`](https://alexseymer.github.io/onedevR/reference/od_query_packages.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_pack(1)
} # }
```
