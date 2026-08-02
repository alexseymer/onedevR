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

GitHub Release v0.1.0 (checklist in
[`RELEASE.md`](https://alexseymer.github.io/onedevR/RELEASE.md); cut
after this branch lands on `main`)

pkgdown site (`_pkgdown.yml` + GitHub Pages workflow →
<https://alexseymer.github.io/onedevR/>)

CRAN name check: `onedevr` appears **available** (no CRAN page as of
2026-08-02). Actual CRAN submission deferred; GitHub (+ optional
R-universe) is the distribution path for v0.1.0.

## Open questions (plan §17)

1.  GitHub org — stay under `alexseymer` or move to a dedicated org?
2.  Function prefix: `od_*` (short) vs `onedev_*` (explicit)?
3.  CRAN, or GitHub + R-universe only? → **v0.1.0: GitHub (+ pkgdown);
    CRAN later**
4.  License: MIT vs GPL-3 (`gitlabr` itself uses GPL-3)? → **MIT for
    now**
5.  Basic Auth support in Phase 1 or deferred to Phase 2? → **deferred
    (Bearer only)**
6.  Return format: plain `list` vs. `tibble` (`gitlabr`-style)?
