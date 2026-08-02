# Low-level OneDev request returning raw bytes

Used for non-JSON endpoints such as streaming build logs
(`Accept: */*`). Prefer
[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
for normal JSON APIs.

## Usage

``` r
.od_request_raw(
  method = "GET",
  endpoint,
  query = NULL,
  body = NULL,
  conn = NULL,
  accept = "*/*",
  timeout = 60
)
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

- accept:

  HTTP Accept header (default `"*/*"`).

- timeout:

  Request timeout in seconds (default `60`).

## Value

Raw vector of the response body.
