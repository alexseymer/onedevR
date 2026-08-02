# Get comments on an issue

Get comments on an issue

## Usage

``` r
od_get_issue_comments(
  issue_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `issue_number` as the internal REST id.

## Value

A tibble of comments (default), or a list when `as_tibble = FALSE`.
