# Parse OneDev streaming build-log binary payload to plain text

Protocol (from tod / OneDev): 4-byte big-endian signed length, then
either a status string (negative length) or a JSON log entry (positive
length) whose `messages[].text` fields are concatenated.

## Usage

``` r
.od_parse_build_log_raw(raw)
```

## Arguments

- raw:

  Raw response body.

## Value

Character vector of log lines (status markers included as `[status] ...`
when present).
