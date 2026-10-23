# Query issues visible on a board

Composes the board's `baseQuery` (or `backlogBaseQuery` when
`backlog = TRUE`) with an optional iteration filter, then calls
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md).
Does not inject `conn$default_issue_state` — board queries already
encode workflow state.

## Usage

``` r
od_query_board_issues(
  board,
  iteration = NULL,
  backlog = FALSE,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  project = NULL,
  conn = NULL
)
```

## Arguments

- board:

  character\|list Board name, or a board list from
  [`od_get_board()`](https://alexseymer.github.io/onedevR/reference/od_get_board.md)
  /
  [`od_list_boards()`](https://alexseymer.github.io/onedevR/reference/od_list_boards.md).

- iteration:

  character\|NULL Optional iteration name to AND into the query
  (`"Iteration" is "…"`). Default: `NULL`.

- backlog:

  logical If `TRUE`, use `backlogBaseQuery` instead of `baseQuery`.
  Default: `FALSE`.

- count:

  integer Maximum number of results (default `100`).

- offset:

  integer Result offset (default `0`).

- as_tibble:

  logical Passed to
  [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md).
  Default: `NULL`.

- project:

  character\|numeric Project path or numeric id when `board` is a name.
  Default: `NULL`.

- conn:

  list Connection list. Default: `NULL`.

## Value

tibble\|list Issues matching the composed board query.

## See also

Other issues:
[`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md),
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md),
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
[`od_get_board()`](https://alexseymer.github.io/onedevR/reference/od_get_board.md),
[`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md),
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
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md),
[`od_unlink_issue_from_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_unlink_issue_from_pull_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_query_board_issues("Development")
od_query_board_issues("Development", iteration = "Sprint 5")
od_query_board_issues("Development", backlog = TRUE)
} # }
```
