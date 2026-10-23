# Clear cached data

Removes cached entries, optionally filtered by a pattern. Useful for
invalidating cache after mutations or resetting specific data.

## Usage

``` r
od_clear_cache(pattern = NULL)
```

## Arguments

- pattern:

  character Optional regex pattern to match cache keys. If `NULL`
  (default), clears all entries. Default: `NULL`.

## Value

integer Count of cleared items.

## See also

Other cache:
[`od_disable_cache()`](https://alexseymer.github.io/onedevR/reference/od_disable_cache.md),
[`od_enable_cache()`](https://alexseymer.github.io/onedevR/reference/od_enable_cache.md),
[`od_get_cache_stats()`](https://alexseymer.github.io/onedevR/reference/od_get_cache_stats.md),
[`od_with_cache()`](https://alexseymer.github.io/onedevR/reference/od_with_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear all cached data
od_clear_cache()

# Clear only issue-related caches
od_clear_cache(pattern = "issues")

# Clear a specific project's data
od_clear_cache(pattern = "projects/123")
} # }
```
