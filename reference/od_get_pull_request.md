# Get a single pull request by UI number

Get a single pull request by UI number

## Usage

``` r
od_get_pull_request(pull_request_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- pull_request_number:

  UI number (`42` or `"#42"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `pull_request_number` as the internal REST id
  (debugging only).

## Value

Parsed pull request object (list).
