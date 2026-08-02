# Package index

## Connection

Configure how onedevr talks to your OneDev instance.

- [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
  : Build an explicit OneDev connection
- [`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md)
  : Set or clear the package-default OneDev connection
- [`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md)
  : Get the package-default OneDev connection
- [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  : Read OneDev connection settings from environment variables

## Issues

- [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md)
  : Query OneDev issues
- [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md)
  : Get a single issue by UI number
- [`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md)
  : Get custom fields for an issue
- [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md)
  : Create a OneDev issue
- [`od_issue_set_description()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_description.md)
  : Set an issue description
- [`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md)
  : Set custom issue fields
- [`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md)
  : Set an issue title
- [`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md)
  : Transition an issue to a new state
- [`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md)
  : Resolve a UI issue number to the internal REST id
- [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md)
  : List iterations for a OneDev project
- [`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md)
  : Set iterations on an existing issue

## Builds

- [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md)
  : Query OneDev builds
- [`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md)
  : Get a single build by UI number
- [`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md)
  : Resolve a UI build number to the internal REST id

## Pull requests

- [`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md)
  : Query OneDev pull requests
- [`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md)
  : Get a single pull request by UI number
- [`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md)
  : Get comments on a pull request
- [`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md)
  : Get reviews on a pull request
- [`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md)
  : Resolve a UI pull request number to the internal REST id

## Projects & low-level

- [`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)
  : Resolve the OneDev project path for a connection
- [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md)
  : Resolve a OneDev project path to its numeric project id
- [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
  : Low-level OneDev REST request
