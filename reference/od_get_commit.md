# Get a single commit

Get a single commit

## Usage

``` r
od_get_commit(
  commit_hash,
  fields = .od_default_commit_fields(),
  project = NULL,
  conn = NULL
)
```

## Arguments

- commit_hash:

  Commit SHA.

- fields:

  Character vector of fields to populate.

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed commit object (list).

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md),
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md),
[`od_get_file_text()`](https://alexseymer.github.io/onedevR/reference/od_get_file_text.md),
[`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md),
[`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md),
[`od_list_tags()`](https://alexseymer.github.io/onedevR/reference/od_list_tags.md),
[`od_query_commits()`](https://alexseymer.github.io/onedevR/reference/od_query_commits.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_commit("abcdef")
} # }
```
