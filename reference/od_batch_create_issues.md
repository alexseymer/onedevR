# Create multiple issues efficiently

Creates multiple issues in batch, optionally reporting progress. Each
issue spec should be a list with `title` (required), and optional
`description`, `fields`, and `iteration_ids`. Uses
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md)
internally.

## Usage

``` r
od_batch_create_issues(issues, progress = TRUE, conn = NULL)
```

## Arguments

- issues:

  list\|tibble List of issue specs, or a tibble with `title` column and
  optional `description`, `fields`, `iteration_ids` columns. Each
  row/element should be a list with at least `title`.

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

- `created`: List of created issue lists (each with `id`, `number`,
  `title`, etc.)

- `numbers`: Numeric vector of created issue numbers

- `errors`: List of errors encountered (empty if all succeeded)

- `summary`: Character vector with status message

## See also

Other batch:
[`od_batch_link_issues_prs()`](https://alexseymer.github.io/onedevR/reference/od_batch_link_issues_prs.md),
[`od_batch_transition_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_transition_issues.md),
[`od_batch_update_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_update_issues.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Create multiple issues from a tibble
issues_to_create <- tibble::tibble(
  title = c("Issue 1", "Issue 2", "Issue 3"),
  description = c("Desc 1", "Desc 2", "Desc 3"),
  fields = list(
    list(Priority = "High"),
    list(Priority = "Normal"),
    list(Priority = "Low")
  )
)
result <- od_batch_create_issues(issues_to_create)
} # }
```
