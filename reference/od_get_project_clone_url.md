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

Parsed clone-url payload (list; typically `httpUrl` / `sshUrl`).
