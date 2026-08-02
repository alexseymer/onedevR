# Query OneDev issues

Query OneDev issues

## Usage

``` r
od_query_issues(
  query = NULL,
  state = NULL,
  count = 100L,
  offset = 0L,
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

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed API response (list). Use the internal normalizer when you need a
flat item list (handles `items` / `data` wrappers).
