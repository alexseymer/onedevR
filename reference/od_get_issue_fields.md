# Get custom fields for an issue

Calls `GET /issues/{id}/fields`. Field names and allowed values are
installation-specific (see `project_plan.md` §10).

## Usage

``` r
od_get_issue_fields(issue_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `issue_number` as the internal REST id (debugging
  only).

## Value

Named list (or map) of field name → value.
