# Transition an issue to a new state

Tries the known body shapes (`list(state=)`, `list(transition=)`, raw
string) - see `project_plan.md` sec 10 and `tod issue change-state`.
State names are installation- and board-specific (e.g. `"Closed"` vs
`"Done"`); use a name that exists on the project's issue board.

## Usage

``` r
od_issue_transition_state(issue_number, state, conn = NULL)
```

## Arguments

- issue_number:

  character\|numeric UI number.

- state:

  character Target state name (e.g. `"Closed"`).

- conn:

  list Connection list. Default: `NULL`.

## Value

list Parsed API response.

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
od_issue_transition_state(145, "Closed")
} # }
```
