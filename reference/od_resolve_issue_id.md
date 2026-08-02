# Resolve a UI issue number to the internal REST id

OneDev UI numbers (`#145`) differ from internal REST `id` values.
High-level helpers always take the UI number. Tries
`"Number" is "<projectPath>#<n>"` then bare `"#n"` / `"n"` (same idea as
[tod](https://github.com/theonedev/tod); bare forms are required on some
OneDev versions).

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
