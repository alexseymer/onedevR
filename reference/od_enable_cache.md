# Enable caching globally for all API requests

Configures global cache settings for the onedevR package. Cache stores
GET requests (idempotent operations) and automatically expires entries
based on TTL. Cache is per-connection (different hosts have separate
caches).

## Usage

``` r
od_enable_cache(ttl_seconds = 3600, max_size = 1000)
```

## Arguments

- ttl_seconds:

  numeric Time to live for cache entries in seconds. Default: `3600` (1
  hour).

- max_size:

  numeric Maximum number of items to cache. Evicts least recently used
  items when exceeded. Default: `1000`.

## Value

invisible(`TRUE`) to allow use in piping contexts.

## See also

Other cache:
[`od_clear_cache()`](https://alexseymer.github.io/onedevR/reference/od_clear_cache.md),
[`od_disable_cache()`](https://alexseymer.github.io/onedevR/reference/od_disable_cache.md),
[`od_get_cache_stats()`](https://alexseymer.github.io/onedevR/reference/od_get_cache_stats.md),
[`od_with_cache()`](https://alexseymer.github.io/onedevR/reference/od_with_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Enable cache with default 1-hour TTL
od_enable_cache()

# Or with custom settings
od_enable_cache(ttl_seconds = 7200, max_size = 500)

# Queries now benefit from caching
issues1 <- od_query_issues()
issues2 <- od_query_issues()  # Served from cache
} # }
```
