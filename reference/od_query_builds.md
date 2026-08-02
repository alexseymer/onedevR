# Query OneDev builds

Query OneDev builds

## Usage

``` r
od_query_builds(
  query = NULL,
  status = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  Raw OneDev build query string (see `tod build get-query-description` /
  OneDev query DSL). Example: `'"Number" is "group/project#100"'`.

- status:

  Optional status filter (e.g. `"SUCCESSFUL"`, `"FAILED"`). Combined
  with `query` via `and`.

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

A tibble of builds (default), or a list when `as_tibble = FALSE`.
