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

## See also

Other pull requests:
[`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md),
[`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
[`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md),
[`od_discard_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_discard_pull_request.md),
[`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md),
[`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md),
[`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md),
[`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
[`od_request_pull_request_changes()`](https://alexseymer.github.io/onedevR/reference/od_request_pull_request_changes.md),
[`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_pull_request_comments(1)
} # }
```
