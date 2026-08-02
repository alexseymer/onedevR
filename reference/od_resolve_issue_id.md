# Resolve a UI issue number to the internal REST id

OneDev UI numbers (`#145`) differ from internal REST `id` values.
High-level helpers always take the UI number; this function queries
`"Number" is "<projectPath>#<n>"` (same convention as
[tod](https://github.com/theonedev/tod)).

## Usage

``` r
od_resolve_issue_id(issue_number, conn = NULL)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character internal issue id.
