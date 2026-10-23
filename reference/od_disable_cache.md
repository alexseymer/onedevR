# Disable caching globally

Disables cache and clears all cached data. Subsequent API requests will
bypass the cache until
[`od_enable_cache()`](https://alexseymer.github.io/onedevR/reference/od_enable_cache.md)
is called again.

## Usage

``` r
od_disable_cache()
```

## Value

invisible(`TRUE`).

## See also

Other cache:
[`od_clear_cache()`](https://alexseymer.github.io/onedevR/reference/od_clear_cache.md),
[`od_enable_cache()`](https://alexseymer.github.io/onedevR/reference/od_enable_cache.md),
[`od_get_cache_stats()`](https://alexseymer.github.io/onedevR/reference/od_get_cache_stats.md),
[`od_with_cache()`](https://alexseymer.github.io/onedevR/reference/od_with_cache.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_disable_cache()
} # }
```
