# Changelog

## onedevr 0.1.0

First public release covering Phases 1–3 of the roadmap.

### Connection

- [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md),
  [`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md),
  [`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md)
  for explicit connections (env vars remain the fallback via
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)).

### Issues

- Query / get / create issues; set title, description, fields;
  transition state.
- [`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md),
  [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md),
  [`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md),
  and `iteration_ids` on
  [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md).
- UI number → internal id resolution
  ([`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md)).

### Builds & pull requests

- [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
  [`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
  [`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md).
- [`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
  [`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md),
  [`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md),
  [`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md),
  [`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md).

### Notes

- High-level helpers always take OneDev **UI numbers** (`#n`), not
  internal REST ids.
- Some write endpoints try multiple body shapes for cross-version OneDev
  compatibility.
- Live integration tests are gated behind `ONEDEV_RUN_LIVE_TESTS=1`.
