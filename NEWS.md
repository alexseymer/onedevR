# onedevr 0.2.0

## API depth

* Issue comments: `od_get_issue_comments()`, `od_add_issue_comment()`.
* Pull request writes: `od_create_pull_request()`, `od_add_pull_request_comment()`,
  `od_approve_pull_request()`, `od_request_pull_request_changes()`,
  `od_merge_pull_request()`, `od_discard_pull_request()`.
* Builds: `od_get_build_params()`, `od_get_build_log()` (parses OneDev streaming
  binary logs to plain text).
* Quote build status criteria as `"Status" is "..."`.

# onedevr 0.1.1

## Fixes (live OneDev hardening)

* Quote state criteria as `"State" is "..."` (unquoted `State is` is rejected by
  some OneDev query parsers).
* Resolve issue/build/PR UI numbers with fallbacks: try `path#n`, then `#n` /
  bare `n` (path-prefixed numbers return HTTP 406 on some instances).
* Send required `offset` / `count` query params for
  `GET /projects/{id}/iterations`.
* Live tests discover real issue/build/PR numbers instead of assuming `#1`.

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
