# Resolve the active OneDev connection

Preference order: explicit `conn`, package default from
[`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md),
then environment via
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md).

## Usage

``` r
.od_conn(conn = NULL, validate = TRUE)
```

## Arguments

- conn:

  Optional connection list.

- validate:

  Passed to
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  when falling back to env.

## Value

A connection list.
