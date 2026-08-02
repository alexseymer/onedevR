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
