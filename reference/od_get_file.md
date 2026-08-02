# Get a file at a revision

Calls `GET /repositories/{projectId}/files/{revision}/{path...}`.

## Usage

``` r
od_get_file(revision, path, project = NULL, conn = NULL)
```

## Arguments

- revision:

  Branch, tag, or commit.

- path:

  File path within the repository.

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed file payload (list; typically includes base64 content).
