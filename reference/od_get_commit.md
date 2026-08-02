# Get a single commit

Get a single commit

## Usage

``` r
od_get_commit(
  commit_hash,
  fields = .od_default_commit_fields(),
  project = NULL,
  conn = NULL
)
```

## Arguments

- commit_hash:

  Commit SHA.

- fields:

  Character vector of fields to populate.

- project:

  Project path or id; defaults to the connection project.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed commit object (list).
