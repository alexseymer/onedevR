# Get a single issue by UI number

Get a single issue by UI number

## Usage

``` r
od_get_issue(issue_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `issue_number` as the internal REST id (debugging
  only).

## Value

Parsed issue object (list).
