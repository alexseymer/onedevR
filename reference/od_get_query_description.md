# Fetch OneDev query DSL description text

Calls `/~api/tod/get-{kind}-query-description` (same source
`tod ... get-query-description` uses). Useful when crafting `query =`
strings for list helpers.

## Usage

``` r
od_get_query_description(
  kind = c("issue", "build", "pull_request", "project"),
  conn = NULL
)
```

## Arguments

- kind:

  One of `"issue"`, `"build"`, `"pull_request"`, or `"project"`.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character scalar (HTML-ish grammar text from the server).

## See also

Other utilities:
[`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md),
[`od_download()`](https://alexseymer.github.io/onedevR/reference/od_download.md),
[`od_paginate()`](https://alexseymer.github.io/onedevR/reference/od_paginate.md),
[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)

## Examples

``` r
if (FALSE) { # \dontrun{
cat(od_get_query_description("build"))
} # }
```
