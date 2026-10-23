# Link multiple issue-PR pairs

Creates links between multiple issue-pull request pairs. Useful for
establishing relationships between issues and PRs in batch.

## Usage

``` r
od_batch_link_issues_prs(links, progress = TRUE, conn = NULL)
```

## Arguments

- links:

  tibble\|data.frame A tibble or data.frame with columns:

  - `issue_number`: UI issue number

  - `pull_request_number`: UI pull request number Each row represents
    one link to create.

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

- `linked`: Numeric vector of issue numbers successfully linked

- `count`: Number of successfully created links

- `errors`: List of errors encountered

- `summary`: Character vector with status message

## See also

Other batch:
[`od_batch_create_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_create_issues.md),
[`od_batch_transition_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_transition_issues.md),
[`od_batch_update_issues()`](https://alexseymer.github.io/onedevR/reference/od_batch_update_issues.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Link multiple issue-PR pairs
links <- tibble::tibble(
  issue_number = c(10, 15, 20),
  pull_request_number = c(42, 43, 44)
)
result <- od_batch_link_issues_prs(links)
} # }
```
