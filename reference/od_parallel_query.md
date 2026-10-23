# Run multiple queries concurrently

Execute a list of query specifications in parallel using futures. Each
query spec is a list containing a function name and its arguments.
Useful for batch retrieving data from multiple endpoints without
blocking.

## Usage

``` r
od_parallel_query(queries = list(), conn = NULL)
```

## Arguments

- queries:

  list List of query specifications. Each element should be a list with
  `fn` (function name as string) and named arguments for that function.
  Example:
  `list(list(fn = "od_query_issues", state = "Open"), list(fn = "od_query_builds", status = "successful"))`.
  Default: [`list()`](https://rdrr.io/r/base/list.html).

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list A list of results in the same order as the input queries. If a
query fails, the error message is returned in its position.

## Details

If `future` is not installed, falls back to sequential execution with a
warning.

## See also

Other concurrent:
[`od_concurrent_stream()`](https://alexseymer.github.io/onedevR/reference/od_concurrent_stream.md),
[`od_map_parallel()`](https://alexseymer.github.io/onedevR/reference/od_map_parallel.md)

## Examples

``` r
if (FALSE) { # \dontrun{
results <- od_parallel_query(
  queries = list(
    list(fn = "od_query_issues", state = "Open", count = 50L),
    list(fn = "od_query_issues", state = "Closed", count = 50L),
    list(fn = "od_query_builds", status = "successful")
  ),
  conn = conn
)
} # }
```
