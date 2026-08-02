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

## See also

Other projects:
[`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
[`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_resolve_project_path()
} # }
```
