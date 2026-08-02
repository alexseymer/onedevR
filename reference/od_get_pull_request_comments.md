# Get comments on a pull request

Get comments on a pull request

## Usage

``` r
od_get_pull_request_comments(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- pull_request_number:

  UI number (`42` or `"#42"`).

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `pull_request_number` as the internal REST id.

## Value

A tibble of comments (default), or a list when `as_tibble = FALSE`.
