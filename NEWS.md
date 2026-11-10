# onedevr 0.7.1

Fixes and a small helper from field use against a real OneDev instance.

## Fixes from the field log

* New `od_whoami()` returns the login name of the current user. When
  `GET /users/me` is refused (HTTP 401/403/404, as seen with some tokens), it
  falls back to the connection's `username` (`ONEDEV_USERNAME`) and otherwise
  explains what to set. `od_get_user_emails()` and the SSH-key helpers use the
  same fallback when called without a `user`. Setting `ONEDEV_USERNAME` together
  with `ONEDEV_AUTH=bearer` keeps token auth.
* List helpers (`od_query_issues()`, `od_query_builds()`,
  `od_query_pull_requests()`, `od_query_projects()`, `od_query_users()`,
  `od_query_groups()`, `od_query_packages()`, `od_list_iterations()`) now page
  automatically when `count` exceeds 100. OneDev rejects larger values with
  HTTP 406 "Count should not be greater than 100"; a request for more records
  is now several requests.
* HTTP error messages that contain an HTML page (for example the 500
  "Interner Fehler" page) are reduced to the page title, and every message is
  limited to 300 characters.
* `od_add_issue_comment()` sends only `issueId` + `content` again. The second
  body shape added in 0.7.0 (`issue = list(id = ...)`) is rejected by OneDev
  with HTTP 400 (unrecognized field `issue`) and only made the error message
  longer. HTTP 500 on this endpoint remains a server-side problem; the help
  page now says to check `od_get_issue_comments()` before retrying.
* New `scripts/diagnose-comments.R` posts probe comments to a scratch issue
  and reports whether the call failed and whether the comment was created
  anyway, to narrow down the HTTP 500 on `POST /issue-comments`.

# onedevr 0.7.0

## Security and vulnerability monitoring

* Raised the minimum `jsonlite` to 1.8.8: earlier versions are affected by
  RSEC-2023-3 (memory leak in the bundled yajl parser).
* New `scripts/audit-deps.R` checks installed and minimum dependency versions
  against the OSV vulnerability database. The `security` workflow runs it
  weekly, on pull requests and on demand, together with a secret scan
  (gitleaks) and CodeQL analysis of the GitHub Actions workflows. Dependabot
  keeps the workflow actions up to date. See `SECURITY.md` for the reporting
  policy.

## Documentation and build

* pkgdown builds again: the `print()`/`str()` methods of `od_connection` are
  documented on the `od_connection` help page instead of in two extra topics
  that were missing from the reference index.
* Version references in README, ROADMAP, the plan and the getting-started
  vignette are consistent with the package version; `man/` is regenerated with
  roxygen2 8.1.1.
* Added an AI-assistance note to the README.
* Fixed README, function-map and workflow-vignette examples that used
  non-existent arguments (`reply_to`, field names passed as `...`), and the
  pkgdown reference index lists all exported topics.

## Tests

* Every exported function is referenced by at least one test (a guard test
  fails otherwise); new tests for the previously untested functions, query
  escaping, cache partitioning, origin checks, `od_error` results and the TLS
  warning.

## Security and correctness (review follow-up)

* Values inserted into OneDev query strings (state, iteration, UI-number
  resolution) are now quoted and escaped (#19).
* `print()` and `str()` of an `od_connection` mask `token` and `password` (#20).
* Response caching is now partitioned by credentials, and `od_request()` uses
  the cache for GET requests when `od_enable_cache()` is on. Before this, the
  cache was never written, so `od_enable_cache()` had no effect (#21).
* Absolute endpoint URLs are only accepted for the configured `host`; other
  origins are refused so credentials are never sent elsewhere (#22).
* `od_parallel_query()` and `od_map_parallel()` return failed items classed as
  `od_error`; the `error` and `message` fields are unchanged (#24).
* A one-time warning is shown when TLS verification is disabled (#25).
* `test-live.R` runs in a weekly and on-demand workflow (`live-tests.yaml`),
  not on pull requests. The batch-create live test only runs when
  `ONEDEV_LIVE_ALLOW_WRITES=1` (#26).
* Examples in `ai-examples` use `od_query_groups()` and `od_get_connection()`;
  a test checks that README and vignettes only call exported functions (#23).

## Iterations, errors and comments (#14-#16)

* `od_resolve_iteration_ids()` maps iteration names to ids; `od_create_issue()`
  and `od_add_issue_iterations()` accept names in `iteration_ids` (#14).
* HTTP 406 "Invalid query" errors include a hint on fuzzy text, board state
  names and `od_get_query_description()` (#15).
* `od_add_issue_comment()` tries a second body shape and reports all variant
  errors on failure (#16).

# onedevr 0.6.0

## Boards and project settings

* `od_get_project_setting()` — `GET /projects/{id}/setting`.
* `od_list_boards()` / `od_get_board()` — read `issueSetting$boardSpecs`.
* `od_query_board_issues()` — compose a board's base/backlog query with an
  optional iteration filter, then call `od_query_issues()` (does not inject
  `default_issue_state`).
* `od_get_iteration()` — resolve an iteration by id or name.

# onedevr 0.5.2

## Bug fixes / DX

* `od_issue_set_title()` / `od_issue_set_description()` try the raw JSON string
  body first, then the object form — avoids OneDev accepting
  `list(title=)` / `list(description=)` and persisting the JSON literal as the
  title or description.
* `.od_request_with_variants()` aggregates every variant error (numbered) when
  all shapes fail, so earlier failures (e.g. unknown state name) are not hidden
  behind a bare-string Jackson `StateTransitionData` message.
* Docs: issue query fuzzy text (`~text~`), board-specific state names, UTF-8
  titles from R vs Windows `cmd` codepage, and PR merge 406 conflicts → rebase
  then retry.

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

## Documentation

* Package hex logo at `man/figures/logo.png` (README + pkgdown favicons),
  following the usual `usethis::use_logo()` / gitlabr layout.
* Expanded getting-started vignette (tibbles, status keywords, jobs, git,
  pagination).
* `\dontrun` examples and `@family` tags on exported helpers; pkgdown reference
  regrouped; internals use `@noRd`.

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
