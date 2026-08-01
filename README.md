# onedevR

`onedevr` is an R client for the [OneDev](https://onedev.io) REST API — issues, projects, and (planned) builds and pull requests, for self-hosted OneDev instances.

**References:**

- R package shape (GitLab → R): [`gitlabr`](https://thinkr-open.github.io/gitlabr/) — low-level `od_request()` escape hatch + high-level `od_*` wrappers, same idea as `gitlab` / `gl_*`.
- Working with OneDev itself: [`tod`](https://github.com/theonedev/tod) (TheOneDev CLI) — issue/PR/build refs, query DSL, and API conventions to mirror when implementing `onedevr`.

## Status

Planning stage. See [`project_plan.md`](project_plan.md) for the full design (architecture, API design, known OneDev API quirks, phased roadmap). This README will grow into real docs as Phase 1 lands — see [`ROADMAP.md`](ROADMAP.md) for current progress.

## Why

There's no established R package for the OneDev REST API as of 2026. Projects, CI scripts, and agents that need programmatic access to OneDev issues/projects currently have to hand-roll HTTP calls. `onedevr` centralizes that: OneDev's API has some quirks (issue UI numbers vs. internal IDs, multiple accepted payload shapes for the same endpoint) that are easy to get wrong once and annoying to get wrong twice.

## Quick start (target API, not yet implemented)

```r
# GitHub (until CRAN, if ever)
remotes::install_github("alexseymer/onedevR")

library(onedevr)

Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = "your-token",
  ONEDEV_PROJECT_PATH = "group/my-project"
)

od_query_issues(state = "Open")
issue <- od_get_issue(145)

created <- od_create_issue(
  title = "API test",
  description = "Created from R",
  fields = list(Priority = "Normal")
)

od_issue_transition_state(created$number, "Closed")
```

## Design notes worth knowing up front

- **Issue numbers are UI numbers, not internal IDs.** OneDev issue `#145` (what you see in the UI) is a different value from the internal REST `id`. The high-level API always takes the UI number; see §9 of the plan.
- **Some OneDev endpoints accept more than one payload shape** depending on version/installation (e.g. issue creation, state transitions). `onedevr` tries known variants rather than picking one and failing silently on others — see §10 of the plan.
- **Custom issue fields are installation-specific.** There's no fixed schema; `fields` is treated as a named list.

## Contributing

Early days — the [plan](project_plan.md) has open questions (§17) that aren't settled yet, including license choice and function-prefix convention. Issues/discussion welcome.

## License

MIT — see [`LICENSE`](LICENSE). (Open question in the plan, see §17 — happy to reconsider GPL-3 if that fits better given `gitlabr` uses it.)
