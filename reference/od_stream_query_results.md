# Stream large query results with chunking

Repeatedly calls a fetcher function (e.g.,
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md))
to retrieve paginated results, calling a callback for each page/chunk.
This is useful for processing large result sets that would be too large
to load entirely into memory.

## Usage

``` r
od_stream_query_results(
  fetcher_fn,
  callback,
  chunk_size = 100L,
  max_pages = 100L,
  as_tibble = NULL,
  progress = FALSE,
  conn = NULL,
  ...
)
```

## Arguments

- fetcher_fn:

  function A function that accepts `offset`, `count`, and optional
  `as_tibble` parameters (e.g.,
  [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
  [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md)).
  Extra arguments are passed via `...`.

- callback:

  function Function called for each chunk. Signature:
  `callback(chunk_df, page_number, has_more)` where:

  - `chunk_df` (tibble or list): the results chunk

  - `page_number` (integer): 1-indexed page number

  - `has_more` (logical): `TRUE` if more pages exist

- chunk_size:

  integer Number of results per page (default `100`). Default: `100L`.

- max_pages:

  integer Safety cap on number of pages (default `100`). Default:
  `100L`.

- as_tibble:

  logical If `TRUE` (default), return results as tibbles to the
  callback. Default: `NULL` (uses fetcher default).

- progress:

  logical If `TRUE`, print progress messages with line count and elapsed
  time (default `FALSE`). Default: `FALSE`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

- ...:

  Additional arguments forwarded to `fetcher_fn` (e.g. `state = "Open"`,
  `query = ...`).

## Value

invisible(list) Invisibly returns a summary list with:

- `total_count`: total number of results processed

- `page_count`: total number of pages fetched

- `elapsed_time`: elapsed time in seconds

## See also

Other streaming:
[`od_chunked_foreach()`](https://alexseymer.github.io/onedevR/reference/od_chunked_foreach.md),
[`od_stream_build_log()`](https://alexseymer.github.io/onedevR/reference/od_stream_build_log.md),
[`od_write_log_file()`](https://alexseymer.github.io/onedevR/reference/od_write_log_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Process all open issues, 50 at a time
od_stream_query_results(
  od_query_issues,
  state = "Open",
  chunk_size = 50L,
  callback = function(chunk_df, page_num, has_more) {
    cat(sprintf("Page %d: %d issues\n", page_num, nrow(chunk_df)))
  }
)

# With progress reporting
od_stream_query_results(
  od_query_builds,
  status = "successful",
  chunk_size = 100L,
  progress = TRUE,
  callback = function(chunk_df, ...) {
    # process each chunk
  }
)
} # }
```
