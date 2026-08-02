# Get the default branch name

Get the default branch name

## Usage

``` r
od_get_default_branch(project = NULL, conn = NULL)
```

## Arguments

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character branch name, or `NULL` if unset (HTTP 204).
