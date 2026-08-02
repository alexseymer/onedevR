# Get tag tip metadata

Get tag tip metadata

## Usage

``` r
od_get_tag(tag, project = NULL, conn = NULL)
```

## Arguments

- tag:

  Tag name.

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

List with `refName` and `commitHash`.
