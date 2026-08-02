# Download a markdown-referenced resource with OneDev auth

Mirrors `tod download`: fetch an absolute or host-relative URL using the
connection credentials and write the body to `path`. Useful for images
and files linked from issue/PR descriptions and comments (OneDev has no
separate attachment list API).

## Usage

``` r
od_download(resource_url, path, conn = NULL)
```

## Arguments

- resource_url:

  Absolute `http(s)` URL or path relative to the OneDev host.

- path:

  Local destination file path.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Normalized destination path, invisibly.
