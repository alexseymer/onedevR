# Get a single iteration by id or name

Resolves against
[`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md)
for the project. Numeric values and digit-only strings match `id`;
otherwise the iteration `name` is matched (case-sensitive).

## Usage

``` r
od_get_iteration(iteration, project = NULL, count = 100L, conn = NULL)
```

## Arguments

- iteration:

  character\|numeric Iteration id or name.

- project:

  Optional project path or numeric id; defaults to the connection's
  project via
  [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md).

- count:

  Maximum iterations to scan when resolving (default `100`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

A single iteration as a list (`id`, `name`, …).

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
od_get_iteration("Sprint 5")
od_get_iteration(17L)
} # }
```
