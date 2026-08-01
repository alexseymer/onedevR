# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is

`onedevr` is a planned **R package** — a client for the OneDev REST API (issues,
projects, later builds/PRs), modeled on `gitlabr`. As of now the repo is
**planning-stage only**: it contains docs (`README.md`, `ROADMAP.md`,
`project_plan.md`) and `LICENSE`. There is **no package code yet** — no
`DESCRIPTION`, `NAMESPACE`, `R/`, `tests/`, or CI. The full intended design
(architecture, API, reference code snippets, test strategy) lives in
[`project_plan.md`](project_plan.md); build Phase 1 from §5–§14 there.

### Toolchain (already installed in the VM snapshot)

- R **4.6.1** from the CRAN apt repo (`cloud.r-project.org/.../noble-cran40`).
- Runtime deps: `httr2`, `jsonlite`, `rlang`.
- Test/dev deps: `testthat`, `mockery`, `withr`, `devtools`, `roxygen2`,
  `knitr`, `rmarkdown`.

Gotcha: the r2u binary CRAN repo (`r2u.stat.illinois.edu`) is configured and is
the fast way to add more CRAN packages: `sudo apt-get install -y r-cran-<name>`
(binary `.deb`, no compilation). Its packages require **R ≥ 4.5/4.6**, which is
why R comes from the CRAN apt repo — Ubuntu 24.04's own `r-base-core` (4.3.3) is
too old for the current r2u binaries. Do not "downgrade" to the distro R.

### Running / testing (once package code exists under `R/` and `tests/`)

Standard R-package commands — see `project_plan.md` §13–§14; no repo-specific
wrappers exist:

- Load for interactive dev: `Rscript -e 'pkgload::load_all(".")'`
- Run tests: `Rscript -e 'devtools::test()'`
- Regenerate docs/NAMESPACE from roxygen: `Rscript -e 'devtools::document()'`
- Full check: `R CMD build . && R CMD check <tarball>` (or `Rscript -e 'devtools::check()'`)

There is no long-running service or GUI — this is a library exercised from R.

### Config / live integration tests

The client reads connection settings from env vars (`project_plan.md` §8):
`ONEDEV_HOST`, `ONEDEV_API_TOKEN` (or `ONEDEV_TOKEN` /
`ONEDEV_ISSUE_REPORTER_API_KEY`), `ONEDEV_PROJECT_PATH`, `ONEDEV_PROJECT_ID`,
`ONEDEV_REPO_URL`, `ONEDEV_ISSUE_STATE`, `ONEDEV_CURL_INSECURE`.

Unit tests are designed to run **offline** (env parsing via `withr`, HTTP paths
stubbed via `mockery`) — no network or real server needed. Live integration
tests are gated behind `ONEDEV_RUN_LIVE_TESTS=1` and additionally require a
reachable OneDev instance plus a valid API token; without those, they skip.
