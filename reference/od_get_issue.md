# Get a single issue by UI number

Get a single issue by UI number

## Usage

``` r
od_get_issue(issue_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- issue_number:

  character\|numeric UI number (`145` or `"#145"`).

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

- use_internal_id:

  logical If `TRUE`, treat `issue_number` as the internal REST id
  (debugging only). Default: `FALSE`.

## Value

list Parsed issue object.

## See also

Other issues:
[`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md),
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md),
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
[`od_get_board()`](https://alexseymer.github.io/onedevR/reference/od_get_board.md),
[`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md),
[`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md),
[`od_get_issue_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_pull_requests.md),
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
od_get_issue(145)
} # }
```
