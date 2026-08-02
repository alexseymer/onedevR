# Resolve a UI build number to the internal REST id

Same Number-query variants as
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md).

## Usage

``` r
od_resolve_build_id(build_number, conn = NULL)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character internal build id.
