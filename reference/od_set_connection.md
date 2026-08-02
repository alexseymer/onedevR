# Set or clear the package-default OneDev connection

After calling this, high-level `od_*` helpers that omit `conn` use the
registered connection instead of reading `ONEDEV_*` environment
variables. Pass `NULL` to clear the default.

## Usage

``` r
od_set_connection(conn)
```

## Arguments

- conn:

  An
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
  (or compatible list), or `NULL` to unset.

## Value

`conn`, invisibly.
