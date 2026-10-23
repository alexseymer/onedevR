# Get pull requests linked to an issue

Retrieves all pull requests that are linked to a specific issue.

## Usage

``` r
od_get_issue_pull_requests(
  issue_number,
  as_tibble = NULL,
  conn = NULL,
  use_internal_id = FALSE
)
```

## Arguments

- issue_number:

  character\|numeric UI issue number (`145` or `"#145"`).

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

  logical If `TRUE`, treat `issue_number` as the internal REST id.
  Default: `FALSE`.

## Value

tibble\|list A tibble of linked pull requests (default), or a list when
`as_tibble = FALSE`.

## See also

Other issues:
[`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md),
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md),
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
[`od_get_board()`](https://alexseymer.github.io/onedevR/reference/od_get_board.md),
[`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md),
[`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md),
[`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md),
[`od_get_iteration()`](https://alexseymer.github.io/onedevR/reference/od_get_iteration.md),
[`od_issue_set_description()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_description.md),
[`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md),
[`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md),
[`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md),
[`od_link_issue_to_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_link_issue_to_pull_request.md),
[`od_list_boards()`](https://alexseymer.github.io/onedevR/reference/od_list_boards.md),
[`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md),
[`od_query_board_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_board_issues.md),
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md),
[`od_unlink_issue_from_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_unlink_issue_from_pull_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_issue_pull_requests(145)
} # }
```
