# Set iterations on an existing issue

Calls `POST /issues/{id}/iterations`. Tries known body shapes (raw id
list and `{iterationIds: [...]}`) via the variants helper — see
`project_plan.md` §10.

## Usage

``` r
od_add_issue_iterations(issue_number, iteration_ids, conn = NULL)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- iteration_ids:

  Numeric iteration ids from
  [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md).

- conn:

  Connection list.

## Value

Parsed API response.
