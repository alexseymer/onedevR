# Convert a OneDev collection payload to a tibble

Flattens list-of-objects responses (from
[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
etc.) into a
[`tibble::tibble()`](https://tibble.tidyverse.org/reference/tibble.html).
Nested objects become list-columns. Pass `as_tibble = FALSE` to get the
raw list of items instead.

## Usage

``` r
od_as_tibble(response, as_tibble = NULL)
```

## Arguments

- response:

  Parsed API response (list).

- as_tibble:

  If `TRUE`, return a tibble; if `FALSE`, a list of items. Default:
  `getOption("onedevr.as_tibble", TRUE)`.

## Value

A tibble, or a list when `as_tibble = FALSE`.

## Details

The package default is controlled by
`options(onedevr.as_tibble = TRUE)`.
