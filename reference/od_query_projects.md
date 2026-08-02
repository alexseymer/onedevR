# Query OneDev projects

Calls `GET /projects` with OneDev's project query DSL (see
`tod project get-query-description` on a live server).

## Usage

``` r
od_query_projects(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)

od_list_projects(
  query = NULL,
  count = 100L,
  offset = 0L,
  as_tibble = NULL,
  conn = NULL
)
```

## Arguments

- query:

  Raw OneDev project query string.

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

A tibble of projects (default), or a list when `as_tibble = FALSE`.
