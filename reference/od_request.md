# Low-level OneDev REST request

Escape hatch for any `/~api/...` endpoint. Prefer high-level `od_*`
helpers when they exist.

## Usage

``` r
od_request(method = "GET", endpoint, query = NULL, body = NULL, conn = NULL)
```

## Arguments

- method:

  character HTTP method (default `"GET"`). Default: `"GET"`.

- endpoint:

  character API path (e.g. `"/issues"`) or absolute URL.

- query:

  list Named list of query parameters (NULLs dropped). Default: `NULL`.

- body:

  list Request body; JSON-encoded with
  [`jsonlite::toJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).
  Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Parsed JSON payload, or `NULL` for empty bodies.

## See also

Other utilities:
[`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md),
[`od_download()`](https://alexseymer.github.io/onedevR/reference/od_download.md),
[`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md),
[`od_paginate()`](https://alexseymer.github.io/onedevR/reference/od_paginate.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_request("GET", "/projects")
} # }
```
