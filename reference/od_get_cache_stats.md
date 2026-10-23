# Get cache statistics

Returns a summary of cache performance including hit rate, number of
items, and total size in bytes.

## Usage

``` r
od_get_cache_stats()
```

## Value

list Statistics with named elements:

- `items`: integer count of cached items

- `size_bytes`: total size of cached data in bytes

- `hit_rate`: cache hit percentage (0-100) or `NA` if no requests
  recorded

- `ttl_remaining`: seconds until the oldest item expires (or `NA` if
  empty)

- `hits`: total cache hits

- `misses`: total cache misses

## See also

Other cache:
[`od_clear_cache()`](https://alexseymer.github.io/onedevR/reference/od_clear_cache.md),
[`od_disable_cache()`](https://alexseymer.github.io/onedevR/reference/od_disable_cache.md),
[`od_enable_cache()`](https://alexseymer.github.io/onedevR/reference/od_enable_cache.md),
[`od_with_cache()`](https://alexseymer.github.io/onedevR/reference/od_with_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_enable_cache()
# ... make some API requests ...
stats <- od_get_cache_stats()
print(stats$hit_rate)  # ~80.5 (percentage)
} # }
```
