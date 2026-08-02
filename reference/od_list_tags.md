# List tags in a project

List tags in a project

## Usage

``` r
od_list_tags(project = NULL, conn = NULL)
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

Character vector of tag names.
