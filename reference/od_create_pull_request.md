# Create a pull request

Create a pull request

## Usage

``` r
od_create_pull_request(
  title,
  source_branch,
  target_branch = "main",
  description = "",
  source_project = NULL,
  target_project = NULL,
  reviewer_ids = NULL,
  assignee_ids = NULL,
  conn = NULL
)
```

## Arguments

- title:

  PR title.

- source_branch:

  Source branch name.

- target_branch:

  Target branch name (default `"main"`).

- description:

  Optional Markdown description.

- source_project:

  Optional source project path/id; defaults to the connection project.

- target_project:

  Optional target project path/id; defaults to `source_project`.

- reviewer_ids:

  Optional numeric user ids.

- assignee_ids:

  Optional numeric user ids.

- conn:

  Connection list.

## Value

Parsed created PR (list), or `NULL` if the server returns an empty body.
