# Resolve a UI issue number to the internal REST id

OneDev UI numbers (`#145`) differ from internal REST `id` values.
High-level helpers always take the UI number. Tries
`"Number" is "<projectPath>#<n>"` then bare `"#n"` / `"n"` (same idea as
[tod](https://github.com/theonedev/tod); bare forms are required on some
OneDev versions).

## Usage

``` r
od_resolve_issue_id(issue_number, conn = NULL)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character internal issue id.

## See also

Other issues:
[`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md),
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md),
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
[`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md),
[`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md),
[`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md),
[`od_issue_set_description()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_description.md),
[`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md),
[`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md),
[`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md),
[`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md),
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_resolve_issue_id(145)
} # }
```
