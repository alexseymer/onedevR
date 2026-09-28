test_that("od_enable_cache sets cache options correctly", {
  # Clean state
  od_disable_cache()

  od_enable_cache(ttl_seconds = 7200, max_size = 500)

  stats <- od_get_cache_stats()
  expect_equal(stats$items, 0)
  expect_true(.onedevr_cache_env$cache_options$enabled)
  expect_equal(.onedevr_cache_env$cache_options$ttl_seconds, 7200L)
  expect_equal(.onedevr_cache_env$cache_options$max_size, 500L)
})

test_that("od_enable_cache requires positive ttl_seconds and max_size", {
  expect_error(
    od_enable_cache(ttl_seconds = -100),
    "must be positive"
  )
  expect_error(
    od_enable_cache(max_size = 0),
    "must be positive"
  )
})

test_that("od_disable_cache disables caching and clears data", {
  od_enable_cache()
  expect_true(.onedevr_cache_env$cache_options$enabled)

  # Add some cache data directly
  .onedevr_cache_env$cache_data$test_key <- "test_value"
  .onedevr_cache_env$cache_metadata$test_key <- list(cached_at = Sys.time())

  od_disable_cache()

  expect_false(.onedevr_cache_env$cache_options$enabled)
  expect_equal(length(ls(.onedevr_cache_env$cache_data)), 0)
  expect_equal(length(ls(.onedevr_cache_env$cache_metadata)), 0)
})

test_that("od_clear_cache removes all cached data when pattern is NULL", {
  od_enable_cache()

  # Add test data
  .onedevr_cache_env$cache_data$key1 <- "value1"
  .onedevr_cache_env$cache_data$key2 <- "value2"
  .onedevr_cache_env$cache_metadata$key1 <- list(cached_at = Sys.time())
  .onedevr_cache_env$cache_metadata$key2 <- list(cached_at = Sys.time())

  expect_equal(length(ls(.onedevr_cache_env$cache_data)), 2)

  cleared <- od_clear_cache()
  expect_equal(cleared, 2)
  expect_equal(length(ls(.onedevr_cache_env$cache_data)), 0)
})

test_that("od_clear_cache with pattern removes matching entries", {
  od_enable_cache()

  # Add test data with different patterns
  .onedevr_cache_env$cache_data$issues_123 <- "data1"
  .onedevr_cache_env$cache_data$issues_456 <- "data2"
  .onedevr_cache_env$cache_data$projects_789 <- "data3"
  .onedevr_cache_env$cache_metadata$issues_123 <- list(cached_at = Sys.time())
  .onedevr_cache_env$cache_metadata$issues_456 <- list(cached_at = Sys.time())
  .onedevr_cache_env$cache_metadata$projects_789 <- list(cached_at = Sys.time())

  cleared <- od_clear_cache(pattern = "issues")
  expect_equal(cleared, 2)
  expect_true(exists("projects_789", envir = .onedevr_cache_env$cache_data))
  expect_false(exists("issues_123", envir = .onedevr_cache_env$cache_data))
})

test_that("od_get_cache_stats returns correct structure", {
  od_disable_cache()
  od_enable_cache()

  # Add test data
  .onedevr_cache_env$cache_data$key1 <- "value1"
  .onedevr_cache_env$cache_data$key2 <- "value2"
  .onedevr_cache_env$cache_metadata$key1 <- list(
    cached_at = Sys.time() - 100,
    accessed_at = Sys.time()
  )
  .onedevr_cache_env$cache_metadata$key2 <- list(
    cached_at = Sys.time(),
    accessed_at = Sys.time()
  )
  .onedevr_cache_env$cache_stats$hits <- 10L
  .onedevr_cache_env$cache_stats$misses <- 5L

  stats <- od_get_cache_stats()

  expect_equal(stats$items, 2)
  expect_true(is.numeric(stats$size_bytes))
  expect_equal(stats$hit_rate, (10 / 15) * 100)
  expect_true(is.numeric(stats$ttl_remaining))
  expect_equal(stats$hits, 10)
  expect_equal(stats$misses, 5)
})

test_that("od_get_cache_stats handles empty cache", {
  od_disable_cache()

  stats <- od_get_cache_stats()

  expect_equal(stats$items, 0)
  expect_equal(stats$size_bytes, 0)
  expect_true(is.na(stats$hit_rate))
  expect_true(is.na(stats$ttl_remaining))
})

test_that("od_with_cache enables cache for expression", {
  od_disable_cache()

  result <- od_with_cache({
    .onedevr_cache_env$cache_options$enabled
  })

  expect_true(result)
  expect_false(.onedevr_cache_env$cache_options$enabled)
})

test_that("od_with_cache restores previous state", {
  od_enable_cache(ttl_seconds = 1000)
  old_ttl <- .onedevr_cache_env$cache_options$ttl_seconds

  od_with_cache(
    {
      .onedevr_cache_env$cache_options$ttl_seconds
    },
    ttl_seconds = 5000
  )

  # TTL should be restored
  expect_equal(.onedevr_cache_env$cache_options$ttl_seconds, old_ttl)
  expect_true(.onedevr_cache_env$cache_options$enabled)
})

test_that(".od_make_cache_key generates consistent hashes", {
  key1 <- .od_make_cache_key("/issues", "GET", list(offset = 0), NULL)
  key2 <- .od_make_cache_key("/issues", "GET", list(offset = 0), NULL)

  expect_identical(key1, key2)
  expect_equal(nchar(key1), 32)  # MD5 hash length
})

test_that(".od_make_cache_key generates different hashes for different inputs", {
  key1 <- .od_make_cache_key("/issues", "GET", list(offset = 0), NULL)
  key2 <- .od_make_cache_key("/projects", "GET", list(offset = 0), NULL)
  key3 <- .od_make_cache_key("/issues", "GET", list(offset = 1), NULL)
  key4 <- .od_make_cache_key("/issues", "POST", list(offset = 0), NULL)

  expect_false(identical(key1, key2))
  expect_false(identical(key1, key3))
  expect_false(identical(key1, key4))
})

test_that(".od_cache_expired correctly identifies expired entries", {
  cache_time <- Sys.time() - 100  # 100 seconds ago
  ttl <- 60

  expect_true(.od_cache_expired(cache_time, ttl))
})

test_that(".od_cache_expired correctly identifies valid entries", {
  cache_time <- Sys.time() - 10  # 10 seconds ago
  ttl <- 60

  expect_false(.od_cache_expired(cache_time, ttl))
})

test_that(".od_get_from_cache returns NULL when cache disabled", {
  od_disable_cache()

  result <- .od_get_from_cache("key", "/issues", "GET")

  expect_null(result)
})

test_that(".od_get_from_cache returns NULL for non-GET requests", {
  od_enable_cache()

  result <- .od_get_from_cache("key", "/issues", "POST")

  expect_null(result)
})

test_that(".od_get_from_cache returns cached value for valid entry", {
  od_enable_cache(ttl_seconds = 3600)

  # Store value in cache
  key <- "test_key"
  expected_value <- list(id = 1, name = "Test")
  .onedevr_cache_env$cache_data[[key]] <- expected_value
  .onedevr_cache_env$cache_metadata[[key]] <- list(
    cached_at = Sys.time(),
    accessed_at = Sys.time()
  )

  result <- .od_get_from_cache(key, "/issues", "GET")

  expect_identical(result, expected_value)
  expect_equal(.onedevr_cache_env$cache_stats$hits, 1)
})

test_that(".od_get_from_cache returns NULL for expired entry", {
  od_enable_cache(ttl_seconds = 10)

  # Store expired value
  key <- "test_key"
  .onedevr_cache_env$cache_data[[key]] <- list(id = 1)
  .onedevr_cache_env$cache_metadata[[key]] <- list(
    cached_at = Sys.time() - 20,  # 20 seconds ago
    accessed_at = Sys.time() - 20
  )

  result <- .od_get_from_cache(key, "/issues", "GET")

  expect_null(result)
  expect_equal(.onedevr_cache_env$cache_stats$misses, 1)
  # Expired entry should be removed
  expect_false(exists(key, envir = .onedevr_cache_env$cache_data))
})

test_that(".od_put_in_cache stores value when cache enabled", {
  od_enable_cache(ttl_seconds = 3600)

  key <- "test_key"
  value <- list(id = 1, name = "Test")

  .od_put_in_cache(key, value, "/issues", "GET")

  expect_true(exists(key, envir = .onedevr_cache_env$cache_data))
  expect_identical(
    get(key, envir = .onedevr_cache_env$cache_data),
    value
  )
  expect_true(exists(key, envir = .onedevr_cache_env$cache_metadata))
})

test_that(".od_put_in_cache does not cache non-GET requests", {
  od_enable_cache(ttl_seconds = 3600)

  key <- "test_key"
  value <- list(id = 1)

  .od_put_in_cache(key, value, "/issues", "POST")

  expect_false(exists(key, envir = .onedevr_cache_env$cache_data))
})

test_that(".od_put_in_cache does not cache when cache disabled", {
  od_disable_cache()

  key <- "test_key"
  value <- list(id = 1)

  .od_put_in_cache(key, value, "/issues", "GET")

  expect_false(exists(key, envir = .onedevr_cache_env$cache_data))
})

test_that(".od_put_in_cache evicts LRU when max_size exceeded", {
  od_enable_cache(ttl_seconds = 3600, max_size = 2)

  # Add first item
  key1 <- "key1"
  .od_put_in_cache(key1, "value1", "/issues", "GET")
  expect_true(exists(key1, envir = .onedevr_cache_env$cache_data))

  # Add second item
  key2 <- "key2"
  .od_put_in_cache(key2, "value2", "/issues", "GET")
  expect_true(exists(key2, envir = .onedevr_cache_env$cache_data))

  # Access key1 so key2 is least recently used
  .od_get_from_cache(key1, "/issues", "GET")

  # Add third item - should evict key2 (least recently used)
  key3 <- "key3"
  .od_put_in_cache(key3, "value3", "/issues", "GET")

  expect_true(exists(key1, envir = .onedevr_cache_env$cache_data))
  expect_false(exists(key2, envir = .onedevr_cache_env$cache_data))
  expect_true(exists(key3, envir = .onedevr_cache_env$cache_data))
})

test_that("Cache stats track hits and misses", {
  od_disable_cache()
  od_enable_cache(ttl_seconds = 3600)

  key <- "test_key"
  .od_put_in_cache(key, "value", "/issues", "GET")

  # First access - hit
  .od_get_from_cache(key, "/issues", "GET")
  expect_equal(.onedevr_cache_env$cache_stats$hits, 1)

  # Second access - hit
  .od_get_from_cache(key, "/issues", "GET")
  expect_equal(.onedevr_cache_env$cache_stats$hits, 2)

  # Miss (non-existent key)
  .od_get_from_cache("nonexistent", "/issues", "GET")
  expect_equal(.onedevr_cache_env$cache_stats$misses, 1)
})

test_that("Cache respects per-connection separation", {
  # Different hosts should have different cache keys
  key1 <- .od_make_cache_key("/issues", "GET", list(), NULL, conn_host = "host1")
  key2 <- .od_make_cache_key("/issues", "GET", list(), NULL, conn_host = "host2")

  expect_false(identical(key1, key2))
})

test_that("Cache integration: end-to-end caching flow", {
  od_disable_cache()
  od_enable_cache(ttl_seconds = 3600)

  endpoint <- "/issues"
  query <- list(offset = 0, count = 10)
  method <- "GET"

  # Create cache key
  key <- .od_make_cache_key(endpoint, method, query)

  # Initially, cache is empty
  expect_null(.od_get_from_cache(key, endpoint, method))
  expect_equal(.onedevr_cache_env$cache_stats$misses, 1)

  # Add to cache
  cached_value <- list(
    list(id = 1, title = "Issue 1"),
    list(id = 2, title = "Issue 2")
  )
  .od_put_in_cache(key, cached_value, endpoint, method)

  # Second access should hit cache
  retrieved <- .od_get_from_cache(key, endpoint, method)
  expect_identical(retrieved, cached_value)
  expect_equal(.onedevr_cache_env$cache_stats$hits, 1)

  # Stats should reflect cache activity
  stats <- od_get_cache_stats()
  expect_equal(stats$items, 1)
  expect_equal(stats$hits, 1)
  expect_equal(stats$misses, 1)
  expect_true(stats$hit_rate > 0)
})
