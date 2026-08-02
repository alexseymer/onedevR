# Read a repository file as text

Convenience wrapper around
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md)
that base64-decodes `base64Content`.

## Usage

``` r
od_get_file_text(
  revision,
  path,
  project = NULL,
  encoding = "UTF-8",
  conn = NULL
)
```

## Arguments

- revision:

  Branch, tag, or commit.

- path:

  File path within the repository.

- project:

  Project path or id; defaults to the connection project.

- encoding:

  Text encoding passed to
  [`base::rawToChar()`](https://rdrr.io/r/base/rawConversion.html)
  context via `iconv` (default `"UTF-8"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character scalar.

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md),
[`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md),
[`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md),
[`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md),
[`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md),
[`od_list_tags()`](https://alexseymer.github.io/onedevR/reference/od_list_tags.md),
[`od_query_commits()`](https://alexseymer.github.io/onedevR/reference/od_query_commits.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_file_text("main", "README.md")
} # }
```
