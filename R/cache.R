# Cache storage environment
.onedevr_cache_env <- new.env(parent = emptyenv())

# Initialize cache metadata
.onedevr_cache_env$cache_data <- list()
.onedevr_cache_env$cache_metadata <- list()
.onedevr_cache_env$cache_stats <- list(
  hits = 0L,
  misses = 0L
)
.onedevr_cache_env$cache_options <- list(
  enabled = FALSE,
  ttl_seconds = 3600L,
  max_size = 1000L
)

#' Generate cache key from request parameters
#'
#' Creates an MD5 hash of the endpoint, method, query params, and body to
#' use as a cache key. Per-connection caching means different hosts have
#' separate caches.
#'
#' @param endpoint {character} API endpoint.
#' @param method {character} HTTP method.
#' @param query {list} Query parameters.
#' @param body {list} Request body.
#' @param conn_host {character} Connection host (for per-host caching).
#'
#' @return {character} MD5 hash as cache key.
#' @noRd
.od_make_cache_key <- function(endpoint, method, query, body, conn_host = "") {
  key_parts <- list(
    endpoint = endpoint,
    method = toupper(method),
    host = conn_host,
    query = paste(names(query), query, sep = "=", collapse = "&"),
    body = if (!is.null(body)) {
      paste(jsonlite::toJSON(body, auto_unbox = TRUE, null = "null"))
    } else {
      ""
    }
  )
  key_str <- paste(unlist(key_parts), collapse = "||")
  digest::digest(key_str, algo = "md5")
}

#' Check if cache entry has expired
#'
#' @param cache_time {numeric} Timestamp when entry was cached.
#' @param ttl_seconds {numeric} Time to live in seconds.
#'
#' @return {logical} `TRUE` if entry has expired.
#' @noRd
.od_cache_expired <- function(cache_time, ttl_seconds) {
  difftime(Sys.time(), cache_time, units = "secs") > ttl_seconds
}

#' Enable caching globally for all API requests
#'
#' Configures global cache settings for the onedevR package. Cache stores
#' GET requests (idempotent operations) and automatically expires entries
#' based on TTL. Cache is per-connection (different hosts have separate caches).
#'
#' @param ttl_seconds {numeric} Time to live for cache entries in seconds.
#'   Default: `3600` (1 hour).
#' @param max_size {numeric} Maximum number of items to cache. Evicts least
#'   recently used items when exceeded. Default: `1000`.
#'
#' @return invisible(`TRUE`) to allow use in piping contexts.
#'
#' @examples
#' \dontrun{
#' # Enable cache with default 1-hour TTL
#' od_enable_cache()
#'
#' # Or with custom settings
#' od_enable_cache(ttl_seconds = 7200, max_size = 500)
#'
#' # Queries now benefit from caching
#' issues1 <- od_query_issues()
#' issues2 <- od_query_issues()  # Served from cache
#' }
#'
#' @family cache
#' @export
od_enable_cache <- function(ttl_seconds = 3600, max_size = 1000) {
  ttl_seconds <- as.numeric(ttl_seconds)[1]
  max_size <- as.numeric(max_size)[1]

  if (ttl_seconds <= 0) {
    stop("`ttl_seconds` must be positive.", call. = FALSE)
  }
  if (max_size <= 0) {
    stop("`max_size` must be positive.", call. = FALSE)
  }

  .onedevr_cache_env$cache_options$enabled <- TRUE
  .onedevr_cache_env$cache_options$ttl_seconds <- as.integer(ttl_seconds)
  .onedevr_cache_env$cache_options$max_size <- as.integer(max_size)

  invisible(TRUE)
}

#' Disable caching globally
#'
#' Disables cache and clears all cached data. Subsequent API requests will
#' bypass the cache until [od_enable_cache()] is called again.
#'
#' @return invisible(`TRUE`).
#'
#' @examples
#' \dontrun{
#' od_disable_cache()
#' }
#'
#' @family cache
#' @export
od_disable_cache <- function() {
  .onedevr_cache_env$cache_options$enabled <- FALSE
  .od_cache_clear_all()
  invisible(TRUE)
}

#' Clear cached data
#'
#' Removes cached entries, optionally filtered by a pattern. Useful for
#' invalidating cache after mutations or resetting specific data.
#'
#' @param pattern {character} Optional regex pattern to match cache keys.
#'   If `NULL` (default), clears all entries. Default: `NULL`.
#'
#' @return {integer} Count of cleared items.
#'
#' @examples
#' \dontrun{
#' # Clear all cached data
#' od_clear_cache()
#'
#' # Clear only issue-related caches
#' od_clear_cache(pattern = "issues")
#'
#' # Clear a specific project's data
#' od_clear_cache(pattern = "projects/123")
#' }
#'
#' @family cache
#' @export
od_clear_cache <- function(pattern = NULL) {
  if (is.null(pattern)) {
    return(.od_cache_clear_all())
  }

  pattern <- as.character(pattern)[1]
  keys_to_remove <- names(.onedevr_cache_env$cache_data)[
    grepl(pattern, names(.onedevr_cache_env$cache_data))
  ]

  for (key in keys_to_remove) {
    rm(list = key, envir = .onedevr_cache_env$cache_data, inherits = FALSE)
    rm(list = key, envir = .onedevr_cache_env$cache_metadata, inherits = FALSE)
  }

  length(keys_to_remove)
}

#' Internal: Clear all cached data
#' @noRd
.od_cache_clear_all <- function() {
  count <- length(ls(.onedevr_cache_env$cache_data))
  rm(list = ls(.onedevr_cache_env$cache_data),
     envir = .onedevr_cache_env$cache_data,
     inherits = FALSE)
  rm(list = ls(.onedevr_cache_env$cache_metadata),
     envir = .onedevr_cache_env$cache_metadata,
     inherits = FALSE)
  .onedevr_cache_env$cache_stats$hits <- 0L
  .onedevr_cache_env$cache_stats$misses <- 0L
  count
}

#' Get cache statistics
#'
#' Returns a summary of cache performance including hit rate, number of items,
#' and total size in bytes.
#'
#' @return {list} Statistics with named elements:
#'   - `items`: integer count of cached items
#'   - `size_bytes`: total size of cached data in bytes
#'   - `hit_rate`: cache hit percentage (0-100) or `NA` if no requests recorded
#'   - `ttl_remaining`: seconds until the oldest item expires (or `NA` if empty)
#'   - `hits`: total cache hits
#'   - `misses`: total cache misses
#'
#' @examples
#' \dontrun{
#' od_enable_cache()
#' # ... make some API requests ...
#' stats <- od_get_cache_stats()
#' print(stats$hit_rate)  # ~80.5 (percentage)
#' }
#'
#' @family cache
#' @export
od_get_cache_stats <- function() {
  keys <- ls(.onedevr_cache_env$cache_data)
  n_items <- length(keys)

  # Calculate total size
  total_size <- 0
  for (key in keys) {
    val <- get(key, envir = .onedevr_cache_env$cache_data)
    total_size <- total_size + object.size(val)
  }

  # Calculate hit rate
  hits <- .onedevr_cache_env$cache_stats$hits
  misses <- .onedevr_cache_env$cache_stats$misses
  total_requests <- hits + misses
  hit_rate <- if (total_requests > 0) {
    (hits / total_requests) * 100
  } else {
    NA_real_
  }

  # Calculate TTL remaining for oldest item
  ttl_remaining <- NA_real_
  if (n_items > 0 && !is.null(.onedevr_cache_env$cache_metadata[[1]])) {
    all_times <- lapply(
      ls(.onedevr_cache_env$cache_metadata),
      function(k) .onedevr_cache_env$cache_metadata[[k]]$cached_at
    )
    oldest_time <- min(do.call(c, all_times))
    elapsed <- as.numeric(difftime(Sys.time(), oldest_time, units = "secs"))
    ttl_remaining <- max(0, .onedevr_cache_env$cache_options$ttl_seconds - elapsed)
  }

  list(
    items = n_items,
    size_bytes = as.numeric(total_size),
    hit_rate = hit_rate,
    ttl_remaining = ttl_remaining,
    hits = hits,
    misses = misses
  )
}

#' Execute code within a cache context
#'
#' Temporarily enables caching for a specific expression, then restores the
#' previous cache state. Useful for caching a specific set of operations
#' without affecting the global cache state.
#'
#' @param expr {expression} R code to execute with caching enabled.
#' @param ttl_seconds {numeric} TTL for cached entries. Default: `3600`.
#'
#' @return The value returned by `expr`.
#'
#' @examples
#' \dontrun{
#' # Cache only a specific set of queries
#' result <- od_with_cache({
#'   issues <- od_query_issues()
#'   projects <- od_query_projects()
#'   list(issues = issues, projects = projects)
#' })
#'
#' # Second call uses cache
#' result2 <- od_with_cache({
#'   od_query_issues()  # Served from cache
#' })
#' }
#'
#' @family cache
#' @export
od_with_cache <- function(expr, ttl_seconds = 3600) {
  old_enabled <- .onedevr_cache_env$cache_options$enabled
  old_ttl <- .onedevr_cache_env$cache_options$ttl_seconds

  on.exit({
    .onedevr_cache_env$cache_options$enabled <- old_enabled
    .onedevr_cache_env$cache_options$ttl_seconds <- old_ttl
  })

  od_enable_cache(ttl_seconds = ttl_seconds)
  eval(substitute(expr), envir = parent.frame())
}

#' Get value from cache if available
#'
#' Internal function used by [od_request()] to check for cached responses.
#' Handles TTL expiration and LRU eviction.
#'
#' @param key {character} Cache key.
#' @param endpoint {character} API endpoint (for cache invalidation patterns).
#' @param method {character} HTTP method.
#' @param conn_host {character} Connection host.
#'
#' @return The cached value if found and not expired, otherwise `NULL`.
#' @noRd
.od_get_from_cache <- function(key, endpoint, method, conn_host = "") {
  if (!.onedevr_cache_env$cache_options$enabled) {
    return(NULL)
  }

  # Only cache GET requests
  if (toupper(method) != "GET") {
    return(NULL)
  }

  if (!exists(key, envir = .onedevr_cache_env$cache_data)) {
    .onedevr_cache_env$cache_stats$misses <-
      .onedevr_cache_env$cache_stats$misses + 1L
    return(NULL)
  }

  metadata <- .onedevr_cache_env$cache_metadata[[key]]
  if (is.null(metadata)) {
    return(NULL)
  }

  ttl <- .onedevr_cache_env$cache_options$ttl_seconds
  if (.od_cache_expired(metadata$cached_at, ttl)) {
    rm(list = key, envir = .onedevr_cache_env$cache_data, inherits = FALSE)
    rm(list = key, envir = .onedevr_cache_env$cache_metadata, inherits = FALSE)
    .onedevr_cache_env$cache_stats$misses <-
      .onedevr_cache_env$cache_stats$misses + 1L
    return(NULL)
  }

  # Update access time for LRU tracking
  metadata$accessed_at <- Sys.time()
  .onedevr_cache_env$cache_metadata[[key]] <- metadata

  .onedevr_cache_env$cache_stats$hits <-
    .onedevr_cache_env$cache_stats$hits + 1L

  get(key, envir = .onedevr_cache_env$cache_data)
}

#' Store value in cache
#'
#' Internal function used by [od_request()] to cache responses.
#' Implements LRU eviction when max_size is exceeded.
#'
#' @param key {character} Cache key.
#' @param value Value to cache.
#' @param endpoint {character} API endpoint.
#' @param method {character} HTTP method.
#' @param conn_host {character} Connection host.
#'
#' @return invisible(`NULL`).
#' @noRd
.od_put_in_cache <- function(key, value, endpoint, method, conn_host = "") {
  if (!.onedevr_cache_env$cache_options$enabled) {
    return(invisible(NULL))
  }

  # Only cache GET requests
  if (toupper(method) != "GET") {
    return(invisible(NULL))
  }

  # Check if we need to evict (LRU)
  cache_size <- length(ls(.onedevr_cache_env$cache_data))
  max_size <- .onedevr_cache_env$cache_options$max_size

  if (cache_size >= max_size) {
    # Find least recently used item
    metadata_keys <- ls(.onedevr_cache_env$cache_metadata)
    if (length(metadata_keys) > 0) {
      access_times <- sapply(
        metadata_keys,
        function(k) {
          meta <- .onedevr_cache_env$cache_metadata[[k]]
          meta$accessed_at %||% meta$cached_at %||% Sys.time()
        }
      )
      lru_key <- metadata_keys[which.min(access_times)]
      rm(list = lru_key, envir = .onedevr_cache_env$cache_data, inherits = FALSE)
      rm(list = lru_key, envir = .onedevr_cache_env$cache_metadata, inherits = FALSE)
    }
  }

  # Store value
  assign(key, value, envir = .onedevr_cache_env$cache_data)

  # Store metadata
  .onedevr_cache_env$cache_metadata[[key]] <- list(
    cached_at = Sys.time(),
    accessed_at = Sys.time(),
    endpoint = endpoint,
    method = method,
    host = conn_host
  )

  invisible(NULL)
}
