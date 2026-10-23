# Write build log to a file

Convenience wrapper around
[`od_stream_build_log()`](https://alexseymer.github.io/onedevR/reference/od_stream_build_log.md)
that writes the build log to a file line-by-line. Returns metadata about
the operation.

## Usage

``` r
od_write_log_file(
  build_number,
  file_path,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
)
```

## Arguments

- build_number:

  character\|numeric UI build number (`100` or `"#100"`).

- file_path:

  character Output file path. Created if it doesn't exist; existing
  files are overwritten. Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

- use_internal_id:

  logical If `TRUE`, treat `build_number` as the internal REST id
  (debugging only). Default: `FALSE`.

- timeout:

  numeric Seconds to wait for the full log stream (default `60`).
  Default: `60`.

## Value

invisible(list) Invisibly returns a summary list with:

- `file_path`: the output file path

- `line_count`: number of lines written

- `file_size`: file size in bytes

## See also

Other streaming:
[`od_chunked_foreach()`](https://alexseymer.github.io/onedevR/reference/od_chunked_foreach.md),
[`od_stream_build_log()`](https://alexseymer.github.io/onedevR/reference/od_stream_build_log.md),
[`od_stream_query_results()`](https://alexseymer.github.io/onedevR/reference/od_stream_query_results.md)

## Examples

``` r
if (FALSE) { # \dontrun{
result <- od_write_log_file(100, "~/build_100.log")
cat(sprintf("Wrote %d lines to %s\n", result$line_count, result$file_path))
} # }
```
