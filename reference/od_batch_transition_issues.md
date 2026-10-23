# Transition multiple issues to a new state

Changes the state of multiple issues atomically. Useful for bulk state
transitions (e.g., closing related issues, reopening a batch).

## Usage

``` r
od_batch_transition_issues(
  issue_numbers,
  target_state,
  progress = TRUE,
  conn = NULL
)
```

## Arguments

- issue_numbers:

  numeric\|character Vector of UI issue numbers.

- target_state:

  character Target state name (e.g., `"Closed"`, `"In Progress"`).

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

- `transitioned`: List of transitioned issue lists

- `count`: Number of successfully transitioned issues

- `errors`: List of errors encountered (e.g., invalid state, issue not
  found)

- `summary`: Character vector with status message

## See also

Other batch:
[`od_batch_create_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_create_issues.md),
[`od_batch_link_issues_prs()`](https://alexseymer.github.io/onedevR/reference/od_batch_link_issues_prs.md),
[`od_batch_update_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_update_issues.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Close multiple issues
numbers <- c(10, 15, 20)
result <- od_batch_transition_issues(numbers, "Closed")
} # }
```
