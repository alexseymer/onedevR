# Get comments on an issue

Get comments on an issue

## Usage

``` r
od_get_issue_comments(issue_number, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- conn:

  Connection list.

- use_internal_id:

  If `TRUE`, treat `issue_number` as the internal REST id.

## Value

Parsed comments payload (list).
