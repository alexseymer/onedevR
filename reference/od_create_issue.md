# Create a OneDev issue

Tries both common create body shapes (`projectId` scalar and
`project = list(id = ...)`) via the internal request-variants helper.

## Usage

``` r
od_create_issue(
  title,
  description = "",
  fields = list(),
  iteration_ids = NULL,
  conn = NULL
)
```

## Arguments

- title:

  Issue title.

- description:

  Issue description (Markdown).

- fields:

  Named list of custom fields (installation-specific).

- iteration_ids:

  Optional numeric iteration ids from
  [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md);
  sent as `iterationIds` in the create body.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Parsed created issue (list).
