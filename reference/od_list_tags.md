# List tags in a project

List tags in a project

## Usage

``` r
od_list_tags(project = NULL, conn = NULL)
```

## Arguments

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character vector of tag names.

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md),
[`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md),
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md),
[`od_get_file_text()`](https://alexseymer.github.io/onedevR/reference/od_get_file_text.md),
[`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md),
[`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md),
[`od_query_commits()`](https://alexseymer.github.io/onedevR/reference/od_query_commits.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_list_tags()
} # }
```
