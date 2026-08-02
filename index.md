# onedevR

`onedevr` is an R client for the [OneDev](https://onedev.io) REST API —
issues, projects, builds, and pull requests, for self-hosted OneDev
instances.

**References:**

- R package shape (GitLab → R):
  [`gitlabr`](https://thinkr-open.github.io/gitlabr/) — low-level
  [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
  escape hatch + high-level `od_*` wrappers, same idea as `gitlab` /
  `gl_*`.
- Working with OneDev itself: [`tod`](https://github.com/theonedev/tod)
  (TheOneDev CLI) — issue/PR/build refs, query DSL, and API conventions
  to mirror when implementing / extending `onedevr`.

## Status

**v0.2.0** adds issue/PR comments, PR write actions, and build logs. See
[`NEWS.md`](https://alexseymer.github.io/onedevR/NEWS.md),
[`ROADMAP.md`](https://alexseymer.github.io/onedevR/ROADMAP.md), and
<https://alexseymer.github.io/onedevR/>.

## Install

``` r

# GitHub
remotes::install_github("alexseymer/onedevR")

# After the GitHub Pages site is live:
# browseVignettes("onedevr")
# or https://alexseymer.github.io/onedevR/
```

## Quick start

``` r

library(onedevr)

# Env-based (fine for interactive use)
Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = "your-token",
  ONEDEV_PROJECT_PATH = "group/my-project"
)

od_query_issues(state = "Open")
issue <- od_get_issue(145)
fields <- od_get_issue_fields(145)

# Or an explicit connection (preferred in scripts)
conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "group/my-project"
)

iterations <- od_list_iterations(conn = conn)
created <- od_create_issue(
  title = "API test",
  description = "Created from R",
  fields = list(Priority = "Normal"),
  iteration_ids = c(iterations[[1]]$id),
  conn = conn
)

od_issue_set_title(created$number, "API test (renamed)", conn = conn)
od_issue_transition_state(created$number, "Closed", conn = conn)

# Builds & pull requests
builds <- od_query_builds(status = "SUCCESSFUL", count = 10L, conn = conn)
pr <- od_get_pull_request(1, conn = conn)
comments <- od_get_pull_request_comments(1, conn = conn)
```

Copy
[`.Renviron.example`](https://alexseymer.github.io/onedevR/.Renviron.example)
to `.Renviron` (gitignored) and fill in your host/token/project.
[`.env.example`](https://alexseymer.github.io/onedevR/.env.example) is
the same variable list for non-R tooling. Live integration tests are
gated behind `ONEDEV_RUN_LIVE_TESTS=1`.

## Design notes worth knowing up front

- **Issue / build / PR numbers are UI numbers, not internal IDs.**
  OneDev `#145` (what you see in the UI) is a different value from the
  internal REST `id`. The high-level API always takes the UI number; see
  §9 of the plan / `tod` ref formats. Resolution tries `projectPath#n`,
  then bare `#n` / `n` for OneDev versions that reject path-prefixed
  numbers.
- **Some OneDev endpoints accept more than one payload shape** depending
  on version/installation (e.g. issue creation, state transitions,
  iterations). `onedevr` tries known variants rather than picking one
  and failing silently on others — see §10 of the plan.
- **Custom issue fields are installation-specific.** There’s no fixed
  schema; `fields` is treated as a named list.
- **Connections:** pass `conn = od_connection(...)` per call, or
  `od_set_connection(conn)` for a package default. Env vars remain the
  fallback.

## Development

``` r

devtools::load_all()
devtools::test()
devtools::document()
devtools::check()
```

## License

MIT — see
[`LICENSE.md`](https://alexseymer.github.io/onedevR/LICENSE.md).
