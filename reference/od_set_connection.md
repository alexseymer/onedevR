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

## See also

Other connection:
[`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md),
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md),
[`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_set_connection(od_connection(host = "https://git.example.test", token = "t", project_path = "p"))
} # }
```
