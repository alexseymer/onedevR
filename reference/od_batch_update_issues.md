# Update multiple issues

Updates multiple issues with selective field updates. Supports updating
`title`, `description`, `fields`, and `state` individually.

## Usage

``` r
od_batch_update_issues(
  issue_numbers,
  updates = list(),
  progress = TRUE,
  conn = NULL
)
```

## Arguments

- issue_numbers:

  numeric\|character Vector of UI issue numbers.

- updates:

  list Named list of updates to apply. Supported keys:

  - `title`: New title (string)

  - `description`: New description (string)

  - `fields`: Named list of custom field updates

  - `state`: New state (string) Only specified keys are updated.

- progress:

  logical If `TRUE` (default), report progress. Default: `TRUE`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Named list with:

- `updated`: List of updated issue lists

- `count`: Number of successfully updated issues

- `errors`: List of errors encountered

- `summary`: Character vector with status message

## See also

Other batch:
[`od_batch_create_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_create_issues.md),
[`od_batch_link_issues_prs()`](https://alexseymer.github.io/onedevR/reference/od_batch_link_issues_prs.md),
[`od_batch_transition_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_transition_issues.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Update multiple issues
numbers <- c(10, 15, 20)
result <- od_batch_update_issues(
  numbers,
  updates = list(
    fields = list(Priority = "High"),
    state = "In Progress"
  )
)
} # }
```
