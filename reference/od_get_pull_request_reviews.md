# Get reviews on a pull request

Get reviews on a pull request

## Usage

``` r
od_get_pull_request_reviews(
  pull_request_number,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- pull_request_number:

  UI number (`42` or `"#42"`).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `pull_request_number` as the internal REST id.

## Value

Parsed reviews payload (list).
