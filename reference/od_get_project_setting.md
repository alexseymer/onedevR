# Get project settings

Calls `GET /projects/{id}/setting`. Includes issue configuration such as
board specs (`issueSetting$boardSpecs`); use
[`od_list_boards()`](https://alexseymer.github.io/onedevR/reference/od_list_boards.md)
for a focused view of boards.

## Usage

``` r
od_get_project_setting(project = NULL, conn = NULL)
```

## Arguments

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

list Parsed project settings object.

## See also

Other projects:
[`od_create_webhook()`](https://alexseymer.github.io/onedevR/reference/od_create_webhook.md),
[`od_delete_webhook()`](https://alexseymer.github.io/onedevR/reference/od_delete_webhook.md),
[`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
[`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md),
[`od_get_webhook()`](https://alexseymer.github.io/onedevR/reference/od_get_webhook.md),
[`od_list_webhooks()`](https://alexseymer.github.io/onedevR/reference/od_list_webhooks.md),
[`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md),
[`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_project_setting()
} # }
```
