# Add a comment to an issue

Posts to `POST /issue-comments` with `issueId` + `content`. A body with
a nested `issue` object is rejected by OneDev (HTTP 400, unrecognized
field `issue`), so only this shape is sent.

## Usage

``` r
od_add_issue_comment(issue_number, content, conn = NULL, user = NULL)
```

## Arguments

- issue_number:

  character\|numeric UI number (`145` or `"#145"`).

- content:

  character Comment body (Markdown).

- conn:

  list Connection list. Default: `NULL`.

- user:

  character\|numeric Optional author: login name or numeric user id,
  sent as `userId`. Default: `NULL`, which uses the current user (id
  from `GET /users/me`, else the login name from
  [`od_whoami()`](https://alexseymer.github.io/onedevR/reference/od_whoami.md)).
  If the current user cannot be determined, no `userId` is sent. A
  `user` that is given but cannot be resolved is an error.

## Value

list Parsed API response.

## Details

The documented request body (OneDev REST API help,
`IssueComment.CREATE_BODY`) also has an optional `userId`, the author of
the comment. By default it is not sent and the server uses the
authenticated user. A request without `userId` returned HTTP 500 on a
live instance, so by default the current user from
[`od_whoami()`](https://alexseymer.github.io/onedevR/reference/od_whoami.md)
is sent. If the current user cannot be determined (for example a token
without an identity), no `userId` is sent. Pass `user` to name the
author explicitly.

Before retrying after an error, check with
[`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md)
whether the comment was created anyway, to avoid duplicates.

## See also

Other issues:
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
[`od_query_board_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_board_issues.md),
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md),
[`od_resolve_iteration_ids()`](https://alexseymer.github.io/onedevR/reference/od_resolve_iteration_ids.md),
[`od_unlink_issue_from_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_unlink_issue_from_pull_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_add_issue_comment(145, "Looks good")
od_add_issue_comment(145, "Looks good", user = "alice")
} # }
```
