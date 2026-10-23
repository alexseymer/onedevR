# Stream build log output with callback processing

Downloads the binary build log stream from OneDev and calls a callback
function for each parsed line. This allows processing large build logs
without loading the entire output into memory. Log lines are extracted
from the streaming binary protocol (see
[`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md)).

## Usage

``` r
od_stream_build_log(
  build_number,
  callback,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
)
```

## Arguments

- build_number:

  character\|numeric UI build number (`100` or `"#100"`).

- callback:

  function Function called for each parsed line. Signature:
  `callback(chunk, line_number, is_last)` where:

  - `chunk` (character): the log line text

  - `line_number` (integer): 1-indexed line number

  - `is_last` (logical): `TRUE` if this is the last line

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

invisible(NULL) Returns invisibly; operates via callback side effects.

## See also

Other streaming:
[`od_chunked_foreach()`](https://alexseymer.github.io/onedevR/reference/od_chunked_foreach.md),
[`od_stream_query_results()`](https://alexseymer.github.io/onedevR/reference/od_stream_query_results.md),
[`od_write_log_file()`](https://alexseymer.github.io/onedevR/reference/od_write_log_file.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Print each line with a line number prefix
od_stream_build_log(100, function(chunk, line_num, is_last) {
  cat(sprintf("%4d: %s\n", line_num, chunk))
})

# Write to a file (see od_write_log_file for a convenience wrapper)
file_conn <- file("build_log.txt", "w")
od_stream_build_log(100, function(chunk, ...) {
  writeLines(chunk, file_conn)
})
close(file_conn)
} # }
```
