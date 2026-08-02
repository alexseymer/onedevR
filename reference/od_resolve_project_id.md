# Resolve a OneDev project path to its numeric project id

Calls `GET /projects/ids/{path}`. If `conn$project_id` is already set,
that value is returned without a network call.

## Usage

``` r
od_resolve_project_id(project = NULL, conn = NULL)
```

## Arguments

- project:

  Optional project path; defaults to
  [`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character project id.
