# Run a CI/CD job

Posts to `POST /job-runs`. Prefer `branch` / `tag` (resolves tip
commit + ref), or pass `commit_hash` + `ref_name` explicitly. For
pull-request merge previews, pass `pull_request_id` (internal REST id).

## Usage

``` r
od_run_job(
  job_name,
  project = NULL,
  branch = NULL,
  tag = NULL,
  commit_hash = NULL,
  ref_name = NULL,
  pull_request_id = NULL,
  params = NULL,
  reason = "Submitted via onedevr",
  conn = NULL
)
```

## Arguments

- job_name:

  Job name from the project build spec.

- project:

  Project path or id; defaults to the connection project.

- branch:

  Branch name (e.g. `"main"`) — mutually exclusive with `tag`,
  `commit_hash`, and `pull_request_id`.

- tag:

  Tag name — mutually exclusive with `branch` / commit / PR modes.

- commit_hash:

  Commit SHA to build (requires `ref_name`).

- ref_name:

  Full git ref (e.g. `"refs/heads/main"`) when using `commit_hash`.

- pull_request_id:

  Internal pull request id (not the UI number).

- params:

  Named list of job parameters (values are character scalars or vectors
  for multi-valued params).

- reason:

  Reason string recorded on the build (required by OneDev).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Internal build id (numeric/character as returned by the API).

## Details

Returns the internal build id (numeric). Use
[`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md)
with `use_internal_id = TRUE` or query by number once known.
