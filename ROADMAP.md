# Roadmap

Mirrors §11 and §18 of
[`project_plan.md`](https://alexseymer.github.io/onedevR/project_plan.md).
Public, and will shift as real API testing against a live OneDev
instance surfaces quirks the plan didn’t anticipate.

## Phase 0 — Planning

Plan document (`project_plan.md`)

GitHub repo created

License decision (MIT)

README skeleton

Maintainer & org decided (currently: personal repo under `alexseymer`)

## Phase 1 — MVP (issue core)

Goal: package installable, tests green, issue CRUD functional.

Package skeleton via `usethis::create_package()`

[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md),
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
— low-level HTTP + env-based config

[`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md),
[`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)

[`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md),
[`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md)

[`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
[`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md),
[`od_issue_set_description()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_description.md),
[`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md),
[`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md)

UI-number → internal-ID resolution tested against mock queries

README quick start (5-minute onboarding)

Estimate per plan: 1–2 working days.

## Phase 2 — Issues+

[`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md)

[`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md),
[`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md)

`od_create_issue(..., iteration_ids =)`

[`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
— explicit connection object instead of env-only

Estimate per plan: 2–3 working days.

## Phase 3 — Builds & Pull Requests

[`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md),
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md),
[`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md)

Pull request listing / review comments:
[`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md),
[`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md),
[`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md),
[`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md),
[`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md)

Estimate per plan: 1 week+.

## Phase 4 — Publishing

GitHub Release v0.1.0 —
<https://github.com/alexseymer/onedevR/releases/tag/v0.1.0>

pkgdown site (`_pkgdown.yml` + GitHub Pages workflow →
<https://alexseymer.github.io/onedevR/>)

CRAN name check: `onedevr` appears **available** (no CRAN page as of
2026-08-02). Actual CRAN submission deferred; GitHub (+ optional
R-universe) is the distribution path for v0.1.0.

## Settled questions (plan §17)

1.  GitHub org — stay under `alexseymer` (no dedicated org for now).
2.  Function prefix — keep `od_*` (mirrors `gitlabr`’s `gl_*`).
3.  Distribution — GitHub + pkgdown; CRAN later if demand warrants it.
4.  License — **MIT**.
5.  Auth — Bearer (token) and **Basic Auth** (`username` +
    `password`/`token`).
6.  Return format — list endpoints return **tibbles** by default
    (`options(onedevr.as_tibble = TRUE)` / `as_tibble = FALSE` to opt
    out); single-object getters and write helpers stay as lists.
