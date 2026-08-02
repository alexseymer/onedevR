# Get parameters for a build

Get parameters for a build

## Usage

``` r
od_get_build_params(build_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- build_number:

  UI number (`100` or `"#100"`).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `build_number` as the internal REST id.

## Value

Parsed params payload (list).
