# Get issues linked to a pull request

Retrieves all issues that are linked to a specific pull request.

## Usage

``` r
od_get_pull_request_issues(
  pull_request_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- pull_request_number:

  character\|numeric UI pull request number (`42` or `"#42"`).

- as_tibble:

  logical If `TRUE` (default via `options(onedevr.as_tibble)`), return a
  tibble via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).
  Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

- use_internal_id:

  logical If `TRUE`, treat `pull_request_number` as the internal REST
  id. Default: `FALSE`.

## Value

tibble\|list A tibble of linked issues (default), or a list when
`as_tibble = FALSE`.

## See also

Other pull requests:
[`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md),
[`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
[`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md),
[`od_discard_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_discard_pull_request.md),
[`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md),
[`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md),
[`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md),
[`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md),
[`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
[`od_request_pull_request_changes()`](https://alexseymer.github.io/onedevR/reference/od_request_pull_request_changes.md),
[`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_pull_request_issues(42)
} # }
```
