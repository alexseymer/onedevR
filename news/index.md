# Changelog

## onedevr 0.4.0

### API surface

- Projects:
  [`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md)
  /
  [`od_list_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md),
  [`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md),
  [`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md).
- Users:
  [`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md),
  [`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md),
  [`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md),
  [`od_resolve_user_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_user_id.md),
  [`od_get_user_emails()`](https://alexseymer.github.io/onedevR/reference/od_get_user_emails.md).
- Build artifacts:
  [`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md),
  [`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md).
- Markdown/resource download with auth:
  [`od_download()`](https://alexseymer.github.io/onedevR/reference/od_download.md)
  (tod-style; OneDev has no separate issue-attachment list API).

## onedevr 0.3.0

### Ergonomics

- List/query getters return tibbles by default
  ([`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
  [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
  [`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
  [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md),
  comment/review getters). Opt out with `as_tibble = FALSE` or
  `options(onedevr.as_tibble = FALSE)`. Helper:
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).
- Basic Auth: `od_connection(username =, password =)` and env vars
  `ONEDEV_USERNAME` / `ONEDEV_PASSWORD` / `ONEDEV_AUTH`. Bearer remains
  the default when only a token is set.
- Roadmap open questions settled (org, prefix, license, auth, return
  format).

## onedevr 0.2.0

### API depth

- Issue comments:
  [`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md),
  [`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md).
- Pull request writes:
  [`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md),
  [`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md),
  [`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md),
  [`od_request_pull_request_changes()`](https://alexseymer.github.io/onedevR/reference/od_request_pull_request_changes.md),
  [`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md),
  [`od_discard_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_discard_pull_request.md).
- Builds:
  [`od_get_build_params()`](https://alexseymer.github.io/onedevR/reference/od_get_build_params.md),
  [`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md)
  (parses OneDev streaming binary logs to plain text).
- Quote build status criteria as `"Status" is "..."`.

## onedevr 0.1.1

### Fixes (live OneDev hardening)

- Quote state criteria as `"State" is "..."` (unquoted `State is` is
  rejected by some OneDev query parsers).
- Resolve issue/build/PR UI numbers with fallbacks: try `path#n`, then
  `#n` / bare `n` (path-prefixed numbers return HTTP 406 on some
  instances).
- Send required `offset` / `count` query params for
  `GET /projects/{id}/iterations`.
- Live tests discover real issue/build/PR numbers instead of assuming
  `#1`.

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
