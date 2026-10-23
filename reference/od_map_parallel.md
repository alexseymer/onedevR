# Apply a function to items in parallel

Execute a function across multiple items concurrently. The function is
called once per item in the list/vector with that item and any
additional arguments passed via `...`. Results maintain the same order
as input items.

## Usage

``` r
od_map_parallel(FUN, items = list(), ..., conn = NULL)
```

## Arguments

- FUN:

  function Function to apply to each item. Called as
  `FUN(item, ..., conn = conn)`.

- items:

  list\|vector Items to process. Each will be passed as the first
  argument to `FUN`. Default:
  [`list()`](https://rdrr.io/r/base/list.html).

- ...:

  Additional arguments passed to `FUN` for every item.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Results from applying `FUN` to each item, in the same order. Failed
items contain an error message.

## Details

If a single item fails, that position in the result list contains an
error message, while other items continue processing. If `future` is not
installed, falls back to sequential execution.

## See also

Other concurrent:
[`od_concurrent_stream()`](https://alexseymer.github.io/onedevR/reference/od_concurrent_stream.md),
[`od_parallel_query()`](https://alexseymer.github.io/onedevR/reference/od_parallel_query.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Fetch multiple issues in parallel
issues <- od_map_parallel(
  FUN = od_get_issue,
  items = c(1, 2, 3, 4, 5),
  conn = conn
)

# Transition multiple issues to "Closed" in parallel
od_map_parallel(
  FUN = od_issue_transition_state,
  items = c(1, 2, 3),
  state = "Closed",
  conn = conn
)
} # }
```
