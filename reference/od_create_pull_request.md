# Create a pull request

Create a pull request

## Usage

``` r
od_create_pull_request(
  title,
  source_branch,
  target_branch = "main",
  description = "",
  source_project = NULL,
  target_project = NULL,
  reviewer_ids = NULL,
  assignee_ids = NULL,
  conn = NULL
)
```

## Arguments

- title:

  character PR title.

- source_branch:

  character Source branch name.

- target_branch:

  character Target branch name (default `"main"`). Default: `"main"`.

- description:

  character Optional Markdown description. Default: `""`.

- source_project:

  character Optional source project path/id; defaults to the connection
  project. Default: `NULL`.

- target_project:

  character Optional target project path/id; defaults to
  `source_project`. Default: `NULL`.

- reviewer_ids:

  numeric Optional numeric user ids. Default: `NULL`.

- assignee_ids:

  numeric Optional numeric user ids. Default: `NULL`.

- conn:

  list Connection list. Default: `NULL`.

## Value

list Parsed created PR, or `NULL` if the server returns an empty body.

## See also

Other pull requests:
[`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md),
[`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
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
od_create_pull_request("Title", source_branch = "feature", target_branch = "main")
} # }
```
