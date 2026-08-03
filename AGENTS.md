# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is

`onedevr` (display name **onedevR**) is an **R package** — a client for
the OneDev REST API (issues, projects, later builds/PRs).

**Two distinct references (do not mix them up):**

| Role | Reference | URL |
|----|----|----|
| R package architecture (GitLab → R) | [`gitlabr`](https://thinkr-open.github.io/gitlabr/) | <https://github.com/ThinkR-open/gitlabr> |
| Working with OneDev (CLI / API shapes, issue/PR/build refs, query DSL) | [`tod`](https://github.com/theonedev/tod) (TheOneDev CLI) | <https://github.com/theonedev/tod> |

`gitlabr` is the model for how an R client should feel (`od_*` ↔︎ `gl_*`,
connection object, low-level escape hatch). `tod` is the authoritative
reference for how OneDev itself is driven — ref formats (`#n`,
`project#n`), issue/PR/build commands, and payload/query conventions.
Prefer `tod`’s
[`cli.md`](https://github.com/theonedev/tod/blob/main/cli.md) and source
over inventing OneDev API shapes.

**Code hosting is GitHub:** <https://github.com/alexseymer/onedevR>
(OneDev is the *API target*, not the VCS). **Phases 1–3 are on `main`.**
Phase 4 adds pkgdown + the `v0.1.0` GitHub Release. Later detail remains
in [`ROADMAP.md`](https://alexseymer.github.io/onedevR/ROADMAP.md) and
[`project_plan.md`](https://alexseymer.github.io/onedevR/project_plan.md).

### Environment (repo-managed via GitHub)

Environment config lives in the repo and travels with the code you push:

- [`.cursor/environment.json`](https://alexseymer.github.io/onedevR/.cursor/environment.json)
  — Dockerfile build + install (dependency refresh) script
- [`.cursor/Dockerfile`](https://alexseymer.github.io/onedevR/.cursor/Dockerfile)
  — `rocker/r-ver:4.6` plus `git`/`sudo` (required by Cursor Cloud),
  system libs, and the baseline runtime/dev toolchain via Posit Package
  Manager binaries

Do **not** rely on a personal/team dashboard snapshot for this repo; the
committed `.cursor/environment.json` takes precedence. Change the image
by editing the Dockerfile and pushing; change dependency refresh by
editing the `install` field (keep it idempotent and free of
service-startup commands).

If a saved dashboard snapshot exists for this repo, delete it so Cloud
Agents rebuild from the Dockerfile (snapshots override
`build.dockerfile`).

### Toolchain baked into the image

- R **4.6** from [`rocker/r-ver`](https://hub.docker.com/r/rocker/r-ver)
  (Ubuntu LTS + Posit Public Package Manager binaries on amd64)
- Cursor Cloud essentials: `git`, `sudo`
- Runtime: `httr2`, `jsonlite`, `rlang`, `tibble`, `vctrs`
- Dev/test: `testthat`, `mockery`, `withr`, `remotes`, `devtools`,
  `roxygen2`, `knitr`, `rmarkdown`, `pkgload`, `pkgdown`

Gotcha: add packages with `install2.r …` or
[`install.packages()`](https://rdrr.io/r/utils/install.packages.html)
(P3M binaries), not `apt install r-cran-*`. The image already sets dual
repos (P3M + CRAN) so `R CMD check` / pkgdown can resolve
`packages.rds`.

### Running / testing

Standard R-package commands — see `project_plan.md` §13–§14; no
repo-specific wrappers exist:

- Load for interactive dev: `Rscript -e 'pkgload::load_all(".")'`
- Run tests: `Rscript -e 'devtools::test()'`
- Regenerate docs/NAMESPACE from roxygen:
  `Rscript -e 'devtools::document()'`
- Full check: `Rscript -e 'devtools::check(args = "--no-manual")'`

There is no long-running service or GUI — this is a library exercised
from R.

### Config / live integration tests

Copy [`.env.example`](https://alexseymer.github.io/onedevR/.env.example)
into `.Renviron` / `.env` (both are gitignored) or set Cursor Cloud
secrets. Vars are documented in `project_plan.md` §8: `ONEDEV_HOST`,
`ONEDEV_API_TOKEN` (or `ONEDEV_TOKEN` /
`ONEDEV_ISSUE_REPORTER_API_KEY`), `ONEDEV_USERNAME` / `ONEDEV_PASSWORD`
/ `ONEDEV_AUTH` (Basic Auth), `ONEDEV_PROJECT_PATH`,
`ONEDEV_PROJECT_ID`, `ONEDEV_REPO_URL`, `ONEDEV_ISSUE_STATE`,
`ONEDEV_CURL_INSECURE`.

Runtime also includes `tibble` (list queries return tibbles by default).

Unit tests are designed to run **offline** (env parsing via `withr`,
HTTP paths stubbed via `mockery`) — no network or real OneDev server
needed. Live integration tests are gated behind
`ONEDEV_RUN_LIVE_TESTS=1` and additionally require a reachable OneDev
instance plus a valid API token; without those, they skip.
