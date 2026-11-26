# Add a comment to a pull request

Posts to `POST /pull-request-comments` with `requestId`, `content` and
`userId`. Without an author OneDev answers HTTP 500 (verified live, as
for issue comments), so the current user is sent by default.

## Usage

``` r
od_add_pull_request_comment(
  pull_request_number,
  content,
  conn = NULL,
  user = NULL
)
```

## Arguments

- pull_request_number:

  character\|numeric UI number.

- content:

  character Comment body (Markdown).

- conn:

  list Connection list. Default: `NULL`.

- user:

  character\|numeric Optional author: login name or numeric user id,
  sent as `userId`. Default: `NULL`, which uses the current user. If the
  current user cannot be determined, no `userId` is sent. A `user` that
  is given but cannot be resolved is an error.

## Value

list Parsed API response.

## See also

Other pull requests:
[`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
[`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md),
[`od_discard_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_discard_pull_request.md),
[`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md),
[`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md),
[`od_get_pull_request_issues()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_issues.md),
[`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md),
[`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md),
[`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
[`od_request_pull_request_changes()`](https://alexseymer.github.io/onedevR/reference/od_request_pull_request_changes.md),
[`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_add_pull_request_comment(1, "LGTM")
} # }
```
