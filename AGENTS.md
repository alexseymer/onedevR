# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is

`onedevr` (display name **onedevR**) is an **R package** — a client for the
OneDev REST API (issues, projects, later builds/PRs).

**Two distinct references (do not mix them up):**

| Role | Reference | URL |
|------|-----------|-----|
| R package architecture (GitLab → R) | [`gitlabr`](https://thinkr-open.github.io/gitlabr/) | https://github.com/ThinkR-open/gitlabr |
| Working with OneDev (CLI / API shapes, issue/PR/build refs, query DSL) | [`tod`](https://github.com/theonedev/tod) (TheOneDev CLI) | https://github.com/theonedev/tod |

`gitlabr` is the model for how an R client should feel (`od_*` ↔ `gl_*`,
connection object, low-level escape hatch). `tod` is the authoritative
reference for how OneDev itself is driven — ref formats (`#n`,
`project#n`), issue/PR/build commands, and payload/query conventions. Prefer
`tod`'s [`cli.md`](https://github.com/theonedev/tod/blob/main/cli.md) and
source over inventing OneDev API shapes.

**Code hosting is GitHub:** https://github.com/alexseymer/onedevR (OneDev is
the *API target*, not the VCS). **Phase 1 (MVP issue core) is implemented** —
`DESCRIPTION`, `R/`, `tests/testthat/`. Later phases are in
[`ROADMAP.md`](ROADMAP.md); design detail remains in
[`project_plan.md`](project_plan.md).

### Environment (repo-managed via GitHub)

Environment config lives in the repo and travels with the code you push:

- [`.cursor/environment.json`](.cursor/environment.json) — Dockerfile build +
  install (dependency refresh) script
- [`.cursor/Dockerfile`](.cursor/Dockerfile) — R 4.6 from the CRAN apt repo,
  r2u binary CRAN packages, and the baseline runtime/dev toolchain

Do **not** rely on a personal/team dashboard snapshot for this repo; the
committed `.cursor/environment.json` takes precedence. Change the image by
editing the Dockerfile and pushing; change dependency refresh by editing the
`install` field (keep it idempotent and free of service-startup commands).

### Toolchain baked into the image

- R **≥ 4.6** from `cloud.r-project.org/.../noble-cran40`
- Runtime: `httr2`, `jsonlite`, `rlang`
- Dev/test: `testthat`, `mockery`, `withr`, `devtools`, `roxygen2`, `knitr`,
  `rmarkdown`

Gotcha: r2u (`r2u.stat.illinois.edu`) is the fast way to add more CRAN packages
(`sudo apt-get install -y r-cran-<name>`). Those binaries need **R ≥ 4.5/4.6** —
Ubuntu 24.04's own `r-base-core` (4.3.3) is too old. The Dockerfile already
pulls R from the CRAN apt repo; do not "downgrade" to the distro R.

### Running / testing

Standard R-package commands — see `project_plan.md` §13–§14; no repo-specific
wrappers exist:

- Load for interactive dev: `Rscript -e 'pkgload::load_all(".")'`
- Run tests: `Rscript -e 'devtools::test()'`
- Regenerate docs/NAMESPACE from roxygen: `Rscript -e 'devtools::document()'`
- Full check: `Rscript -e 'devtools::check(args = "--no-manual")'`

There is no long-running service or GUI — this is a library exercised from R.

### Config / live integration tests

Copy [`.env.example`](.env.example) into `.Renviron` / `.env` (both are
gitignored) or set Cursor Cloud secrets. Vars are documented in
`project_plan.md` §8: `ONEDEV_HOST`, `ONEDEV_API_TOKEN` (or `ONEDEV_TOKEN` /
`ONEDEV_ISSUE_REPORTER_API_KEY`), `ONEDEV_PROJECT_PATH`, `ONEDEV_PROJECT_ID`,
`ONEDEV_REPO_URL`, `ONEDEV_ISSUE_STATE`, `ONEDEV_CURL_INSECURE`.

Unit tests are designed to run **offline** (env parsing via `withr`, HTTP paths
stubbed via `mockery`) — no network or real OneDev server needed. Live
integration tests are gated behind `ONEDEV_RUN_LIVE_TESTS=1` and additionally
require a reachable OneDev instance plus a valid API token; without those,
they skip.
