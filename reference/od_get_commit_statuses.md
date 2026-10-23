# Get commit statuses

Retrieves all statuses set on a commit from various systems.

## Usage

``` r
od_get_commit_statuses(
  commit_hash,
  project = NULL,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- commit_hash:

  Commit SHA.

- project:

  Project path or numeric id; defaults to the connection project.

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

A tibble of commit statuses (default), or a list when
`as_tibble = FALSE`.

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md),
[`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md),
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md),
[`od_get_file_text()`](https://alexseymer.github.io/onedevR/reference/od_get_file_text.md),
[`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md),
[`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md),
[`od_list_tags()`](https://alexseymer.github.io/onedevR/reference/od_list_tags.md),
[`od_query_commits()`](https://alexseymer.github.io/onedevR/reference/od_query_commits.md),
[`od_set_commit_status()`](https://alexseymer.github.io/onedevR/reference/od_set_commit_status.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_commit_statuses("abc123def456")
} # }
```
