# Get build log lines

Downloads `/~api/streaming/build-logs/{id}` and parses OneDev's binary
log stream into plain-text lines (same idea as `tod build get-log`).

## Usage

``` r
od_get_build_log(
  build_number,
  conn = NULL,
  use_internal_id = FALSE,
  timeout = 60
)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

- timeout:

  Seconds to wait for the full log stream (default `60`).

## Value

Character vector of log lines.
