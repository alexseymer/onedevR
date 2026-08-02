# Resolve the OneDev project path for a connection

Uses `conn$project_path`, falling back to deriving a path from
`conn$repo_url` (git remote URL).

## Usage

``` r
od_resolve_project_path(conn = NULL)
```

## Arguments

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character project path (e.g. `"group/my-project"`).
