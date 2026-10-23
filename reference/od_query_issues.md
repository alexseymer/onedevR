# Query OneDev issues

For fuzzy title/description search use OneDev text criteria such as
`~GeoJSON~` (see
[`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md)
with `kind = "issue"`). Forms like `"Title" contains "…"` are often
rejected (HTTP 406) by the issue query parser — prefer the server
grammar from `od_get_query_description("issue")`.

## Usage

``` r
od_query_issues(
  query = NULL,
  state = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  character Raw OneDev issue query string (see
  [`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md)
  / OneDev query DSL). Example: `'"Number" is "group/project#145"'`.
  Default: `NULL`.

- state:

  character Optional state filter (e.g. `"Open"`). Combined with `query`
  via `and`. When both are empty, falls back to
  `conn$default_issue_state` (`ONEDEV_ISSUE_STATE`). Default: `NULL`.

- count:

  integer Maximum number of results (default `100`).

- offset:

  integer Result offset (default `0`).

- as_tibble:

  logical If `TRUE` (default via `options(onedevr.as_tibble)`), return a
  tibble via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md);
  if `FALSE`, the raw list payload / items. Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

tibble\|list A tibble of issues (default), or a list when
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
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md),
[`od_unlink_issue_from_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_unlink_issue_from_pull_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_query_issues(state = "Open", count = 20L)
od_query_issues(query = "~GeoJSON~")
} # }
```
