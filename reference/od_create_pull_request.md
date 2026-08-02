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

  PR title.

- source_branch:

  Source branch name.

- target_branch:

  Target branch name (default `"main"`).

- description:

  Optional Markdown description.

- source_project:

  Optional source project path/id; defaults to the connection project.

- target_project:

  Optional target project path/id; defaults to `source_project`.

- reviewer_ids:

  Optional numeric user ids.

- assignee_ids:

  Optional numeric user ids.

- conn:

  Connection list.

## Value

Parsed created PR (list), or `NULL` if the server returns an empty body.

## See also

Other pull requests:
[`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md),
[`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
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
od_create_pull_request("Title", source_branch = "feature", target_branch = "main")
} # }
```
