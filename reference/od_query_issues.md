# Query OneDev issues

Query OneDev issues

## Usage

``` r
od_query_issues(
  query = NULL,
  state = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  Raw OneDev issue query string (see `tod issue get-query-description` /
  OneDev query DSL). Example: `'"Number" is "group/project#145"'`.

- state:

  Optional state filter (e.g. `"Open"`). Combined with `query` via
  `and`. When both are empty, falls back to `conn$default_issue_state`
  (`ONEDEV_ISSUE_STATE`).

- count:

  Maximum number of results (default `100`).

- offset:

  Result offset (default `0`).

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md);
  if `FALSE`, the raw list payload / items.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

A tibble of issues (default), or a list when `as_tibble = FALSE`.
