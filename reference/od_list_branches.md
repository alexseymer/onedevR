# List branches in a project

List branches in a project

## Usage

``` r
od_list_branches(project = NULL, conn = NULL)
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

Character vector of branch names.
