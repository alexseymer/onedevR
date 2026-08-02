# onedevr 0.1.0

First public release covering Phases 1–3 of the roadmap.

## Connection

* `od_connection()`, `od_set_connection()`, `od_get_connection()` for
  explicit connections (env vars remain the fallback via `od_get_config()`).

## Issues

* Query / get / create issues; set title, description, fields; transition state.
* `od_get_issue_fields()`, `od_list_iterations()`, `od_add_issue_iterations()`,
  and `iteration_ids` on `od_create_issue()`.
* UI number → internal id resolution (`od_resolve_issue_id()`).

## Builds & pull requests

* `od_query_builds()`, `od_get_build()`, `od_resolve_build_id()`.
* `od_query_pull_requests()`, `od_get_pull_request()`,
  `od_resolve_pull_request_id()`, `od_get_pull_request_comments()`,
  `od_get_pull_request_reviews()`.

## Notes

* High-level helpers always take OneDev **UI numbers** (`#n`), not internal
  REST ids.
* Some write endpoints try multiple body shapes for cross-version OneDev
  compatibility.
* Live integration tests are gated behind `ONEDEV_RUN_LIVE_TESTS=1`.
