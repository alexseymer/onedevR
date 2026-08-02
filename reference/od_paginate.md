# Paginate a list/query helper until exhausted

Repeatedly calls `fetcher(offset, count)` (and optional `as_tibble`)
until a short page is returned or `max_pages` is hit. Designed for
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
[`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
etc.

## Usage

``` r
od_paginate(fetcher, ..., page_size = 100L, max_pages = 100L, as_tibble = NULL)
```

## Arguments

- fetcher:

  A function that accepts at least `offset` and `count`. Extra arguments
  may be passed via `...`.

- ...:

  Forwarded to `fetcher` (e.g. `state = "Open"`, `query = ...`).

- page_size:

  Page size / `count` (default `100`).

- max_pages:

  Safety cap on number of pages (default `100`).

- as_tibble:

  Passed to `fetcher` when it has a formal `as_tibble`.

## Value

A combined tibble when pages are tibbles; otherwise a concatenated list
of items.

## See also

Other utilities:
[`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md),
[`od_download()`](https://alexseymer.github.io/onedevR/reference/od_download.md),
[`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md),
[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_paginate(od_query_issues, state = "Open", page_size = 50L)
} # }
```
