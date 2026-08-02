# Resolve a markdown resource URL against the OneDev host

Absolute `http(s)` URLs are returned unchanged; relative URLs are
resolved against `host` (same idea as `tod download`).

## Usage

``` r
.od_resolve_markdown_url(host, resource_url)
```

## Arguments

- host:

  OneDev base URL (no `/~api` suffix).

- resource_url:

  Absolute or relative resource URL from markdown.

## Value

Absolute URL string.
