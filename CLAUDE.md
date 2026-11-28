# Project CLAUDE.md

Complements `/opt/devbox/CLAUDE.md` for this repository. `AGENTS.md` and
`CONTRIBUTING.md` hold the full detail; this file is the short version.

## Project overview

`onedevr` (display name **onedevR**) is an R client for the OneDev REST
API: issues, iterations, boards, builds, pull requests, projects, users,
packages. Public, general-purpose, `od_*` prefix, modelled on `gitlabr`.
OneDev is the API target; code is hosted on GitHub
(`alexseymer/onedevR`). A change is done when it meets the Definition of
Done in `project_plan.md` §11: roxygen docs with example, `_pkgdown.yml`
entry, at least one offline test, a `NEWS.md` entry, no new
`R CMD check` warnings.

## Stack

- R package (`DESCRIPTION`), R 4.6. Runtime deps: `httr2`, `jsonlite`,
  `rlang`, `tibble`, `vctrs` (fixed dependency budget, enforced by
  `tests/testthat/test-principles.R`).
- Dev: `testthat`, `mockery`, `withr`, `devtools`, `roxygen2`, `knitr`,
  `rmarkdown`, `pkgdown`.
- External: a OneDev instance, only for live tests. pkgdown site on
  GitHub Pages (`gh-pages` branch).
- `.cursor/Dockerfile` defines the Cursor Cloud image, not a runtime
  service.

## How to build and test

``` sh
Rscript -e 'devtools::document()'                  # regenerate man/ and NAMESPACE
Rscript -e 'devtools::test()'                      # offline unit tests
Rscript -e 'devtools::check(args = "--no-manual")' # full check
Rscript -e 'pkgdown::check_pkgdown()'              # every export in _pkgdown.yml
```

On the devbox, R is not installed on the host; run these in the dev
image built from `.cursor/Dockerfile`:

``` sh
docker build -f .cursor/Dockerfile -t onedevr-dev .cursor
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work \
  -e HOME=/tmp onedevr-dev Rscript -e 'devtools::test()'
```

Live tests: `ONEDEV_RUN_LIVE_TESTS=1` plus `ONEDEV_HOST` and a token in
`.Renviron` (gitignored; see `.env.example` and `LIVE-TESTS.md`). R
reads the mounted `.Renviron` in the container; pass
`-e ONEDEV_RUN_LIVE_TESTS=1`. Writing tests also need
`ONEDEV_LIVE_ALLOW_WRITES=1`. Never print or commit those values. The
`live-tests.yaml` workflow uses repository secrets of the same names.
Comment debugging: `scripts/diagnose-comments.R`.

## Conventions

- Linux principle (`CONTRIBUTING.md`, “Design principles”): one function
  per OneDev operation, object first, `conn` and options last, no
  prompts, no stdout output from library code (use
  [`message()`](https://rdrr.io/r/base/message.html)).
- Edit roxygen comments in `R/`, never `man/*.Rd` or `NAMESPACE` by
  hand.
- Unit tests stay offline (stub HTTP with `mockery`, env with `withr`).
- Unverified areas are marked experimental; promote only after a live
  test.
- Distribution is GitHub only (releases, pkgdown on GitHub Pages). Never
  submit to CRAN or R-universe or publish anywhere else without an
  explicit instruction; `--as-cran` runs are local checks only.
- Commits: imperative summary line, one topic per branch, merged via PR.
  Every user-visible change gets a `NEWS.md` entry.

## Personas in this project

`.agents/personas/agy-reviewer.md` overrides the global persona
(`ask-agy` looks in the repo first): coverage checklist, before/after
scenario per changed function, self-check with quoted lines, and the
onedevr-specific checks. Cursor: roxygen docs, offline tests, mechanical
refactors. agy: review before a release and of API-shape decisions that
are not backed by `tod` or the OneDev REST help.

Prepare agy reviews with `scripts/review-prep.sh <from> [<to>]`. It uses
the `ocr` CLI (Open Code Review,
`npm i -g @alibaba-group/open-code-review`) in delegation mode, which
needs no LLM and no key, and prints the reviewable files, the rules per
file and the diffs as one Markdown bundle. Give that bundle to agy in a
single call.
