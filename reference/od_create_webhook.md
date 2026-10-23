# Create a webhook for a project

Creates a new webhook that will POST events to the specified URL.

## Usage

``` r
od_create_webhook(url, events = NULL, project = NULL, conn = NULL)
```

## Arguments

- url:

  character Target URL where webhook events will be POSTed.

- events:

  character Character vector of event types to trigger on (e.g.,
  c("push", "pull_request")). Omit or pass `NULL` for all events.
  Default: `NULL`.

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

list Parsed webhook object with ID and configuration.

## See also

Other projects:
[`od_delete_webhook()`](https://alexseymer.github.io/onedevR/reference/od_delete_webhook.md),
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
od_create_webhook("https://example.com/webhook", events = c("push", "pull_request"))
} # }
```
