# Process a stream of items with concurrent workers

Apply a function across a potentially large list of items using a
configurable number of concurrent workers. Useful for bulk operations
with built-in rate limiting and worker pool management.

## Usage

``` r
od_concurrent_stream(items, FUN, max_workers = 4L, ..., conn = NULL)
```

## Arguments

- items:

  list\|vector Items to process.

- FUN:

  function Function to apply to each item. Called as
  `FUN(item, ..., conn = conn)`.

- max_workers:

  integer Maximum number of concurrent workers (default `4`). Set lower
  for rate-limited APIs. Default: `4`.

- ...:

  Additional arguments passed to `FUN` for every item.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Combined results from all items, in the same order. Failed items
contain error messages.

## Details

If `future` is not installed, falls back to sequential execution.

## See also

Other concurrent:
[`od_map_parallel()`](https://alexseymer.github.io/onedevR/reference/od_map_parallel.md),
[`od_parallel_query()`](https://alexseymer.github.io/onedevR/reference/od_parallel_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Bulk update many issues with 2 workers to avoid rate limiting
results <- od_concurrent_stream(
  items = 1:100,
  FUN = function(issue_num) {
    od_issue_set_fields(
      issue_number = issue_num,
      fields = list(Status = "In Progress")
    )
  },
  max_workers = 2,
  conn = conn
)
} # }
```
