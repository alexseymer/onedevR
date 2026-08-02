# Get labels for a package

Get labels for a package

## Usage

``` r
od_get_pack_labels(pack_id, as_tibble = NULL, conn = NULL)
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

A tibble of labels (default), or a list when `as_tibble = FALSE`.
