# onedevr 0.5.1

## Dogfood hardening

* Fix `od_query_builds(status =)`: OneDev uses keyword criteria (`successful`,
  `failed`, …), not `"Status" is "..."`. Enum spellings like `SUCCESSFUL` map
  automatically.
* `od_query_pull_requests(status = "open"|"merged"|"discarded")`.
* `od_get_query_description()` for issue/build/PR/project DSL text.
* `od_paginate()` to walk `offset`/`count` list endpoints.
* `od_get_file_text()` decodes repository file content.
* Clone-url docs use actual field names `http` / `ssh`.

# onedevr 0.5.0

## Jobs, packages, and git

* Job control: `od_run_job()`, `od_rebuild_job()`, `od_cancel_job()`.
* Packages: `od_query_packages()`, `od_get_pack()`, `od_get_pack_blobs()`,
  `od_get_pack_labels()`.
* Repository: `od_list_branches()`, `od_get_branch()`, `od_get_default_branch()`,
  `od_list_tags()`, `od_get_tag()`, `od_query_commits()`, `od_get_commit()`,
  `od_get_file()`.

# onedevr 0.4.0

## API surface

* Projects: `od_query_projects()` / `od_list_projects()`, `od_get_project()`,
  `od_get_project_clone_url()`.
* Users: `od_query_users()`, `od_get_user()`, `od_get_me()`,
  `od_resolve_user_id()`, `od_get_user_emails()`.
* Build artifacts: `od_list_build_artifacts()`, `od_download_build_artifact()`.
* Markdown/resource download with auth: `od_download()` (tod-style; OneDev has
  no separate issue-attachment list API).

# onedevr 0.3.0

## Ergonomics

* List/query getters return tibbles by default (`od_query_issues()`,
  `od_query_builds()`, `od_query_pull_requests()`, `od_list_iterations()`,
  comment/review getters). Opt out with `as_tibble = FALSE` or
  `options(onedevr.as_tibble = FALSE)`. Helper: `od_as_tibble()`.
* Basic Auth: `od_connection(username =, password =)` and env vars
  `ONEDEV_USERNAME` / `ONEDEV_PASSWORD` / `ONEDEV_AUTH`. Bearer remains the
  default when only a token is set.
* Roadmap open questions settled (org, prefix, license, auth, return format).

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
