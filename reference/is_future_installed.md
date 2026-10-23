# Check if future package is available

Helper function to verify that the `future` package is installed. If not
available, suggests installation and can optionally fall back to
sequential processing.

## Usage

``` r
is_future_installed(fallback = TRUE)
```

## Arguments

- fallback:

  logical If `TRUE` (default), issues a warning and returns `FALSE` to
  trigger fallback to sequential processing. If `FALSE`, stops with an
  error. Default: `TRUE`.

## Value

logical `TRUE` if `future` is installed, `FALSE` if not and fallback is
enabled.

## Examples

``` r
if (FALSE) { # \dontrun{
if (is_future_installed()) {
  # Use future-based parallel processing
}
} # }
```
