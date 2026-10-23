# Delete a webhook

Removes a webhook from a project.

## Usage

``` r
od_delete_webhook(webhook_id, project = NULL, conn = NULL)
```

## Arguments

- webhook_id:

  character\|numeric Numeric webhook ID.

- project:

  character\|numeric Project path or numeric id; defaults to the
  connection project. Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Parsed API response (typically `NULL` on success).

## See also

Other projects:
[`od_create_webhook()`](https://alexseymer.github.io/onedevR/reference/od_create_webhook.md),
[`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
[`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md),
[`od_get_project_setting()`](https://alexseymer.github.io/onedevR/reference/od_get_project_setting.md),
[`od_get_webhook()`](https://alexseymer.github.io/onedevR/reference/od_get_webhook.md),
[`od_list_webhooks()`](https://alexseymer.github.io/onedevR/reference/od_list_webhooks.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md),
[`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_delete_webhook(1)
} # }
```
