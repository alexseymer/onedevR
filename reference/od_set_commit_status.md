# Set or update a commit status

Sets the status of a commit (e.g., from a CI system) for visibility in
the web UI.

## Usage

``` r
od_set_commit_status(
  commit_hash,
  state,
  context,
  description = NULL,
  target_url = NULL,
  project = NULL,
  conn = NULL
)
```

## Arguments

- commit_hash:

  Commit SHA.

- state:

  Status state (e.g., `"pending"`, `"success"`, `"failure"`, `"error"`).

- context:

  Context identifier for this status (e.g.,
  `"continuous-integration/my-ci"`).

- description:

  Optional description of the status.

- target_url:

  Optional URL to the CI build/check details.

- project:

  Project path or numeric id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed commit status object (list).

## See also

Other repository:
[`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md),
[`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md),
[`od_get_commit_statuses()`](https://alexseymer.github.io/onedevR/reference/od_get_commit_statuses.md),
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
od_set_commit_status(
  "abc123def456",
  state = "success",
  context = "ci/build"
)
} # }
```
