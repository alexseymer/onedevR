# Process results in fixed-size chunks

A convenience wrapper around
[`od_stream_query_results()`](https://alexseymer.github.io/onedevR/reference/od_stream_query_results.md)
for batch processing. If no callback is provided, yields results as a
list of chunks (useful with
[`lapply()`](https://rdrr.io/r/base/lapply.html) or for saving to disk).
If a callback is provided, it is called for each chunk and the return
value is `NULL`.

## Usage

``` r
od_chunked_foreach(
  fetcher_fn,
  chunk_size = 100L,
  callback = NULL,
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

- chunk_size:

  integer Number of results per chunk (default `100`). Default: `100L`.

- callback:

  function Optional callback. If provided, called for each chunk and
  results are not returned. Signature:
  `callback(chunk_df, chunk_num, has_more)`. Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

- ...:

  Additional arguments forwarded to `fetcher_fn`.

## Value

list If `callback = NULL`: a list of chunks (each chunk is a tibble or
list). Otherwise: `invisible(NULL)`.

## See also

Other streaming:
[`od_stream_build_log()`](https://alexseymer.github.io/onedevR/reference/od_stream_build_log.md),
[`od_stream_query_results()`](https://alexseymer.github.io/onedevR/reference/od_stream_query_results.md),
[`od_write_log_file()`](https://alexseymer.github.io/onedevR/reference/od_write_log_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Collect all issues in 50-item chunks, return as list
chunks <- od_chunked_foreach(od_query_issues, chunk_size = 50L, state = "Open")
lapply(chunks, function(chunk) {
  cat(sprintf("Chunk with %d issues\n", nrow(chunk)))
})

# Or use with a callback and side effects
od_chunked_foreach(
  od_query_builds,
  chunk_size = 100L,
  callback = function(chunk, chunk_num, ...) {
    write.csv(chunk, sprintf("builds_chunk_%d.csv", chunk_num))
  }
)
} # }
```
