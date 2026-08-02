# Low-level OneDev REST request

Escape hatch for any `/~api/...` endpoint. Prefer high-level `od_*`
helpers when they exist.

## Usage

``` r
od_request(method = "GET", endpoint, query = NULL, body = NULL, conn = NULL)
```

## Arguments

- method:

  HTTP method (default `"GET"`).

- endpoint:

  API path (e.g. `"/issues"`) or absolute URL.

- query:

  Named list of query parameters (NULLs dropped).

- body:

  Request body; JSON-encoded with
  [`jsonlite::toJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed JSON payload (list), or `NULL` for empty bodies.

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
