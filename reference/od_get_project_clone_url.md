# Get clone URLs for a project

Get clone URLs for a project

## Usage

``` r
od_get_project_clone_url(project = NULL, conn = NULL)
```

## Arguments

- project:

  Project path or numeric id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed clone-url payload (list; typically `http` and `ssh`).

## See also

Other projects:
[`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md),
[`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_project_clone_url()
} # }
```
