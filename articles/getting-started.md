# Getting started with onedevr

## Overview

`onedevr` is an R client for self-hosted [OneDev](https://onedev.io)
REST APIs. It follows the same shape as
[`gitlabr`](https://thinkr-open.github.io/gitlabr/) (`od_*` helpers +
[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
escape hatch) and mirrors OneDev conventions from the
[`tod`](https://github.com/theonedev/tod) CLI.

**Important:** high-level helpers take **UI numbers** (`145` /
`"#145"`), not internal REST ids.

## Configure a connection

### Environment variables

``` r

library(onedevr)

Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = "your-token",
  ONEDEV_PROJECT_PATH = "group/my-project"
)

od_query_issues(state = "Open")
```

See `.env.example` in the repository for the full variable list.

### Explicit connection

``` r

conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "group/my-project"
)

od_set_connection(conn) # optional package default
od_get_issue(145, conn = conn)
```

## Issues

``` r

issue <- od_get_issue(145)
fields <- od_get_issue_fields(145)

created <- od_create_issue(
  title = "API test",
  description = "Created from R",
  fields = list(Priority = "Normal")
)

od_issue_set_title(created$number, "API test (renamed)")
od_issue_transition_state(created$number, "Closed")
```

Iterations (sprint/version-like objects in OneDev):

``` r

iterations <- od_list_iterations()
od_add_issue_iterations(145, iteration_ids = iterations$id[1])
```

## Builds and pull requests

``` r

builds <- od_query_builds(status = "SUCCESSFUL", count = 10L)
build <- od_get_build(100)

pr <- od_get_pull_request(1)
comments <- od_get_pull_request_comments(1)
reviews <- od_get_pull_request_reviews(1)
```

## Low-level escape hatch

``` r

issue_id <- od_resolve_issue_id(145)
raw <- od_request("GET", paste0("/issues/", issue_id))
```
