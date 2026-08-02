# Package index

## Connection

Configure how onedevr talks to your OneDev instance (env, explicit
connection, Basic Auth or Bearer).

- [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
  : Build an explicit OneDev connection
- [`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md)
  : Set or clear the package-default OneDev connection
- [`od_get_connection()`](https://alexseymer.github.io/onedevR/reference/od_get_connection.md)
  : Get the package-default OneDev connection
- [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  : Read OneDev connection settings from environment variables

## Issues

Query and mutate issues, fields, comments, and iterations.

- [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md)
  : Query OneDev issues
- [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md)
  : Get a single issue by UI number
- [`od_get_issue_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_comments.md)
  : Get comments on an issue
- [`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md)
  : Get custom fields for an issue
- [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md)
  : Create a OneDev issue
- [`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md)
  : Add a comment to an issue
- [`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md)
  : Set iterations on an existing issue
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

## Builds and jobs

Query builds, logs, artifacts, and run/rebuild/cancel jobs.

- [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md)
  : Query OneDev builds
- [`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md)
  : Get a single build by UI number
- [`od_get_build_params()`](https://alexseymer.github.io/onedevR/reference/od_get_build_params.md)
  : Get parameters for a build
- [`od_get_build_log()`](https://alexseymer.github.io/onedevR/reference/od_get_build_log.md)
  : Get build log lines
- [`od_list_build_artifacts()`](https://alexseymer.github.io/onedevR/reference/od_list_build_artifacts.md)
  : List build artifact metadata
- [`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md)
  : Download a build artifact to a local file
- [`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md)
  : Resolve a UI build number to the internal REST id
- [`od_run_job()`](https://alexseymer.github.io/onedevR/reference/od_run_job.md)
  : Run a CI/CD job
- [`od_rebuild_job()`](https://alexseymer.github.io/onedevR/reference/od_rebuild_job.md)
  : Rebuild (resubmit) a finished or existing build
- [`od_cancel_job()`](https://alexseymer.github.io/onedevR/reference/od_cancel_job.md)
  : Cancel a running build

## Pull requests

List, review, and write pull requests.

- [`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md)
  : Query OneDev pull requests
- [`od_get_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request.md)
  : Get a single pull request by UI number
- [`od_get_pull_request_comments()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_comments.md)
  : Get comments on a pull request
- [`od_get_pull_request_reviews()`](https://alexseymer.github.io/onedevR/reference/od_get_pull_request_reviews.md)
  : Get reviews on a pull request
- [`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md)
  : Create a pull request
- [`od_add_pull_request_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_pull_request_comment.md)
  : Add a comment to a pull request
- [`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md)
  : Approve a pull request
- [`od_request_pull_request_changes()`](https://alexseymer.github.io/onedevR/reference/od_request_pull_request_changes.md)
  : Request changes on a pull request
- [`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md)
  : Merge a pull request
- [`od_discard_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_discard_pull_request.md)
  : Discard a pull request
- [`od_resolve_pull_request_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_pull_request_id.md)
  : Resolve a UI pull request number to the internal REST id

## Projects

Resolve and inspect OneDev projects.

- [`od_query_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md)
  [`od_list_projects()`](https://alexseymer.github.io/onedevR/reference/od_query_projects.md)
  : Query OneDev projects
- [`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md)
  : Get a single project
- [`od_get_project_clone_url()`](https://alexseymer.github.io/onedevR/reference/od_get_project_clone_url.md)
  : Get clone URLs for a project
- [`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md)
  : Resolve the OneDev project path for a connection
- [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md)
  : Resolve a OneDev project path to its numeric project id

## Users

- [`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md)
  : Query OneDev users

- [`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md)
  : Get a single user

- [`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md)
  :

  Get the authenticated user (`/users/me`)

- [`od_resolve_user_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_user_id.md)
  : Resolve a OneDev login name to its numeric user id

- [`od_get_user_emails()`](https://alexseymer.github.io/onedevR/reference/od_get_user_emails.md)
  : Get email addresses for a user

## Packages

- [`od_query_packages()`](https://alexseymer.github.io/onedevR/reference/od_query_packages.md)
  : Query OneDev packages
- [`od_get_pack()`](https://alexseymer.github.io/onedevR/reference/od_get_pack.md)
  : Get a package by id
- [`od_get_pack_blobs()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_blobs.md)
  : Get blobs for a package
- [`od_get_pack_labels()`](https://alexseymer.github.io/onedevR/reference/od_get_pack_labels.md)
  : Get labels for a package

## Repository

Branches, tags, commits, and file contents.

- [`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md)
  : List branches in a project
- [`od_get_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_branch.md)
  : Get branch tip metadata
- [`od_get_default_branch()`](https://alexseymer.github.io/onedevR/reference/od_get_default_branch.md)
  : Get the default branch name
- [`od_list_tags()`](https://alexseymer.github.io/onedevR/reference/od_list_tags.md)
  : List tags in a project
- [`od_get_tag()`](https://alexseymer.github.io/onedevR/reference/od_get_tag.md)
  : Get tag tip metadata
- [`od_query_commits()`](https://alexseymer.github.io/onedevR/reference/od_query_commits.md)
  : Query repository commits
- [`od_get_commit()`](https://alexseymer.github.io/onedevR/reference/od_get_commit.md)
  : Get a single commit
- [`od_get_file()`](https://alexseymer.github.io/onedevR/reference/od_get_file.md)
  : Get a file at a revision
- [`od_get_file_text()`](https://alexseymer.github.io/onedevR/reference/od_get_file_text.md)
  : Read a repository file as text

## Utilities

Tibbles, pagination, query DSL help, downloads, and the low-level HTTP
escape hatch.

- [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md)
  : Convert a OneDev collection payload to a tibble
- [`od_paginate()`](https://alexseymer.github.io/onedevR/reference/od_paginate.md)
  : Paginate a list/query helper until exhausted
- [`od_get_query_description()`](https://alexseymer.github.io/onedevR/reference/od_get_query_description.md)
  : Fetch OneDev query DSL description text
- [`od_download()`](https://alexseymer.github.io/onedevR/reference/od_download.md)
  : Download a markdown-referenced resource with OneDev auth
- [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
  : Low-level OneDev REST request
