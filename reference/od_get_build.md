# Get a single build by UI number

Get a single build by UI number

## Usage

``` r
od_get_build(build_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id (debugging
  only).

## Value

Parsed build object (list).
