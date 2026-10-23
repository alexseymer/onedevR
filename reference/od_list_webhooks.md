# List webhooks for a project

Retrieves all webhooks configured for a project.

## Usage

``` r
od_list_webhooks(project = NULL, as_tibble = NULL, conn = NULL)
```

## Arguments

- project:

  character\|numeric Project path or numeric id; defaults to the
  connection project. Default: `NULL`.

- as_tibble:

  logical If `TRUE` (default via `options(onedevr.as_tibble)`), return a
  tibble via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).
  Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

tibble\|list A tibble of webhooks (default), or a list when
`as_tibble = FALSE`.

## See also

Other projects:
[`od_create_webhook()`](https://alexseymer.github.io/onedevR/reference/od_create_webhook.md),
[`od_delete_webhook()`](https://alexseymer.github.io/onedevR/reference/od_delete_webhook.md),
[`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
[`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md),
[`od_get_project_setting()`](https://alexseymer.github.io/onedevR/reference/od_get_project_setting.md),
[`od_get_webhook()`](https://alexseymer.github.io/onedevR/reference/od_get_webhook.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md),
[`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_list_webhooks()
} # }
```
