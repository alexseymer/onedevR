# Execute code within a cache context

Temporarily enables caching for a specific expression, then restores the
previous cache state. Useful for caching a specific set of operations
without affecting the global cache state.

## Usage

``` r
od_with_cache(expr, ttl_seconds = 3600)
```

## Arguments

- expr:

  expression R code to execute with caching enabled.

- ttl_seconds:

  numeric TTL for cached entries. Default: `3600`.

## Value

The value returned by `expr`.

## See also

Other cache:
[`od_clear_cache()`](https://alexseymer.github.io/onedevR/reference/od_clear_cache.md),
[`od_disable_cache()`](https://alexseymer.github.io/onedevR/reference/od_disable_cache.md),
[`od_enable_cache()`](https://alexseymer.github.io/onedevR/reference/od_enable_cache.md),
[`od_get_cache_stats()`](https://alexseymer.github.io/onedevR/reference/od_get_cache_stats.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Cache only a specific set of queries
result <- od_with_cache({
  issues <- od_query_issues()
  projects <- od_query_projects()
  list(issues = issues, projects = projects)
})

# Second call uses cache
result2 <- od_with_cache({
  od_query_issues()  # Served from cache
})
} # }
```
