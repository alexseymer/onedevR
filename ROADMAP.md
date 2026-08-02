# Roadmap

Mirrors §11 and §18 of [`project_plan.md`](project_plan.md). Public, and will shift as real API testing against a live OneDev instance surfaces quirks the plan didn't anticipate.

## Phase 0 — Planning
- [x] Plan document (`project_plan.md`)
- [x] GitHub repo created
- [x] License decision (MIT)
- [x] README skeleton
- [x] Maintainer & org decided (currently: personal repo under `alexseymer`)

## Phase 1 — MVP (issue core)
Goal: package installable, tests green, issue CRUD functional.

- [x] Package skeleton via `usethis::create_package()`
- [x] `od_request()`, `od_get_config()` — low-level HTTP + env-based config
- [x] `od_resolve_project_id()`, `od_resolve_project_path()`
- [x] `od_query_issues()`, `od_resolve_issue_id()`, `od_get_issue()`
- [x] `od_create_issue()`, `od_issue_set_title()`, `od_issue_set_description()`, `od_issue_set_fields()`, `od_issue_transition_state()`
- [x] UI-number → internal-ID resolution tested against mock queries
- [x] README quick start (5-minute onboarding)

Estimate per plan: 1–2 working days.

## Phase 2 — Issues+
- [x] `od_get_issue_fields()`
- [x] `od_list_iterations()`, `od_add_issue_iterations()`
- [x] `od_create_issue(..., iteration_ids =)`
- [x] `od_connection()` — explicit connection object instead of env-only

Estimate per plan: 2–3 working days.

## Phase 3 — Builds & Pull Requests
- [x] `od_query_builds()`, `od_get_build()`, `od_resolve_build_id()`
- [x] Pull request listing / review comments:
  `od_query_pull_requests()`, `od_get_pull_request()`,
  `od_resolve_pull_request_id()`, `od_get_pull_request_comments()`,
  `od_get_pull_request_reviews()`

Estimate per plan: 1 week+.

## Phase 4 — Publishing
- [x] GitHub Release v0.1.0 — https://github.com/alexseymer/onedevR/releases/tag/v0.1.0
- [x] pkgdown site (`_pkgdown.yml` + GitHub Pages workflow →
  https://alexseymer.github.io/onedevR/)
- [x] CRAN name check: `onedevr` appears **available** (no CRAN page as of
  2026-08-02). Actual CRAN submission deferred; GitHub (+ optional R-universe)
  is the distribution path for v0.1.0.

## Settled questions (plan §17)

1. GitHub org — stay under `alexseymer` (no dedicated org for now).
2. Function prefix — keep `od_*` (mirrors `gitlabr`'s `gl_*`).
3. Distribution — GitHub + pkgdown; CRAN later if demand warrants it.
4. License — **MIT**.
5. Auth — Bearer (token) and **Basic Auth** (`username` + `password`/`token`).
6. Return format — list endpoints return **tibbles** by default
   (`options(onedevr.as_tibble = TRUE)` / `as_tibble = FALSE` to opt out);
   single-object getters and write helpers stay as lists.

## Beyond Phase 4

- [x] Ergonomics (v0.3.0): tibbles + Basic Auth
- [x] Projects / users / build artifacts / download (v0.4.0)
- [x] Job run / rebuild / cancel (v0.5.0)
- [x] Packages + repository commit helpers (v0.5.0)
- [ ] R-universe / CRAN when demand warrants it
