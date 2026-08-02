# Query repository commits

Calls `GET /repositories/{projectId}/commits`.

## Usage

``` r
od_query_commits(
  query = NULL,
  count = 100L,
  fields = .od_default_commit_fields(),
  project = NULL,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  OneDev commit query (same syntax as the commits page), e.g.
  `"since tag(v1.0.0) until tag(v2.0.0)"`.

- count:

  Maximum number of commits (default `100`).

- fields:

  Character vector of fields to populate (default includes
  author/subject/body/parents/dates).

- project:

  Project path or id; defaults to the connection project.

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

A tibble of commits (default), or a list when `as_tibble = FALSE`.

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md),
[`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md),
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md),
[`od_get_file_text()`](https://alexseymer.github.io/onedevR/reference/od_get_file_text.md),
[`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md),
[`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md),
[`od_list_tags()`](https://alexseymer.github.io/onedevR/reference/od_list_tags.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_query_commits(count = 10L)
} # }
```
