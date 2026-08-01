# Roadmap

Mirrors §11 and §18 of [`project_plan.md`](project_plan.md). Public, and will shift as real API testing against a live OneDev instance surfaces quirks the plan didn't anticipate.

## Phase 0 — Planning
- [x] Plan document (`project_plan.md`)
- [x] GitHub repo created
- [ ] License decision (MIT vs GPL-3 — see plan §17)
- [ ] README skeleton
- [ ] Maintainer & org decided (currently: personal repo under `alexseymer`)

## Phase 1 — MVP (issue core)
Goal: package installable, tests green, issue CRUD functional.

- [ ] Package skeleton via `usethis::create_package()`
- [ ] `od_request()`, `od_get_config()` — low-level HTTP + env-based config
- [ ] `od_resolve_project_id()`, `od_resolve_project_path()`
- [ ] `od_query_issues()`, `od_resolve_issue_id()`, `od_get_issue()`
- [ ] `od_create_issue()`, `od_issue_set_title()`, `od_issue_set_description()`, `od_issue_set_fields()`, `od_issue_transition_state()`
- [ ] UI-number → internal-ID resolution tested against mock queries
- [ ] README quick start (5-minute onboarding)

Estimate per plan: 1–2 working days.

## Phase 2 — Issues+
- [ ] `od_get_issue_fields()`
- [ ] `od_list_iterations()`, `od_add_issue_iterations()`
- [ ] `od_create_issue(..., iteration_ids =)`
- [ ] `od_connection()` — explicit connection object instead of env-only

Estimate per plan: 2–3 working days.

## Phase 3 — Builds & Pull Requests
- [ ] `od_query_builds()`, `od_get_build()`, `od_resolve_build_id()`
- [ ] Pull request listing / review comments (scope depends on what `~help/api` exposes per instance)

Estimate per plan: 1 week+.

## Phase 4 — Publishing
- [ ] GitHub Release v0.1.0
- [ ] pkgdown site
- [ ] CRAN submission or R-universe (optional — package name `onedevr` availability on CRAN not yet checked)

## Open questions (plan §17)

1. GitHub org — stay under `alexseymer` or move to a dedicated org?
2. Function prefix: `od_*` (short) vs `onedev_*` (explicit)?
3. CRAN, or GitHub + R-universe only?
4. License: MIT vs GPL-3 (`gitlabr` itself uses GPL-3)?
5. Basic Auth support in Phase 1 or deferred to Phase 2?
6. Return format: plain `list` vs. `tibble` (`gitlabr`-style)?
