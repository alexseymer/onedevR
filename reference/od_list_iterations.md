# List iterations for a OneDev project

Calls `GET /projects/{id}/iterations`. Iteration ids are installation-
and project-specific; use them with
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md)
or
[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md)'s
`iteration_ids` argument.

## Usage

``` r
od_list_iterations(
  project = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- project:

  Optional project path or numeric id; defaults to the connection's
  project via
  [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md).

- count:

  Maximum number of results (default `100`).

- offset:

  Result offset (default `0`).

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

A tibble of iterations (default), or a list when `as_tibble = FALSE`.
